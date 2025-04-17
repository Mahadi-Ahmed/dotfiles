#!/bin/bash

# This bash script sets up 3 aliases:
#
# awsall - list all available AWS profiles
# awswho - shows the current active AWS profile
# awsp   - Switch to the provided profile name
#
# If a profile has the configuration entry "mfa_serial", its value is expected to
# be a serial ID for an MFA device used with that profile account.
# The "mfa_serial" configuration is normally only used by role profiles by the AWS CLI,
# but the awsp alias supports this in order to allow MFA usage with regular user profiles.
#
function _getCredentialsFile() {
    local credentialFileLocation=${AWS_SHARED_CREDENTIALS_FILE};
    if [ -z $credentialFileLocation ]; then
        credentialFileLocation=~/.aws/credentials
    fi
    echo $credentialFileLocation
};
function _awsListAll() {
    local credentialFileLocation=$(_getCredentialsFile)
    while read line; do
        if [[ $line == "["* ]]; then echo "$line"; fi;
    done < $credentialFileLocation;
};
function _awsSwitchProfile() {
    if [ -z $1 ]; then  echo "Usage: awsp profilename"; return; fi
    local role_arn="$(aws configure get role_arn --profile $1)"
    local key_exists="$(aws configure get aws_access_key_id --profile $1)"
    local mfa_serial="$(aws configure get mfa_serial --profile $1)"
    if [[ -n $key_exists ]]; then
        aws configure set aws_access_key_id "$(aws configure get aws_access_key_id --profile $1)"
        aws configure set aws_secret_access_key "$(aws configure get aws_secret_access_key --profile $1)"
        aws configure set aws_session_token "$(aws configure get aws_session_token --profile $1)"
        aws configure set region "$(aws configure get region --profile $1)"
        echo "Switched to AWS Profile as default: $1";
        if [[ -n $mfa_serial ]]; then
            _awsMfaAuthenticate $mfa_serial $1
        fi
        aws configure list
    elif [[ -n $role_arn ]]; then
        _awsAssumeRole $role_arn $1
        echo "Assumed role associated with profile $1"
        aws configure list
    fi
};
function _awsAssumeRole() {
    local role_arn=$1
    local profile=$2
    export PYTHONIOENCODING=utf8
    local source_profile=$(aws configure get source_profile --profile "${profile}")
    local role_session_name=$(aws iam get-user --query User.UserName --output text --profile "${source_profile}")
    local credentials_json=$(aws sts assume-role --role-arn "${role_arn}" --role-session-name cli-"${role_session_name}" --profile "${source_profile}")
    if [[ -n ${credentials_json} ]]; then
        local credentials=$(python -c "from __future__ import print_function; import sys,json; credentials=json.load(sys.stdin)['Credentials']; print(credentials['AccessKeyId'], credentials['SecretAccessKey'], credentials['SessionToken'])" <<<$credentials_json)
        read access_key_id secret_access_key session_token <<<${credentials}
        aws configure set default.aws_access_key_id "$access_key_id"
        aws configure set default.aws_secret_access_key "$secret_access_key"
        aws configure set default.aws_session_token "$session_token"
    fi
};
function _awsMfaAuthenticate() {
    local mfa_serial=$1
    local profile=$2
    read "?Enter MFA token (6 digits) for profile ${profile}:" mfa_token 
    export PYTHONIOENCODING=utf8
    local credentials_json=$(aws sts get-session-token --serial-number "${mfa_serial}" --token-code "${mfa_token}")
    if [[ -n ${credentials_json} ]]; then
        local credentials=$(python -c "from __future__ import print_function; import sys,json; credentials=json.load(sys.stdin)['Credentials']; print(credentials['AccessKeyId'], credentials['SecretAccessKey'], credentials['SessionToken'])" <<<$credentials_json)
        read access_key_id secret_access_key session_token <<<${credentials}
        aws configure set default.aws_access_key_id "$access_key_id"
        aws configure set default.aws_secret_access_key "$secret_access_key"
        aws configure set default.aws_session_token "$session_token"
        aws configure set aws_access_key_id "${access_key_id}" --profile "${profile}"-temp
        aws configure set aws_secret_access_key "${secret_access_key}" --profile "${profile}"-temp
        aws configure set aws_session_token "${session_token}" --profile "${profile}"-temp
        echo "Enabled temporary session for profile ${profile} as default and ${profile}-temp"
    else
        echo "***>>> Invalid MFA code and/or serial id, not authenticated with MFA <<<***"
    fi
};
function _awsSetEnv() {
    local profilename="$1"
    if [[ -z "$profilename" ]]; then
        unset AWS_ACCESS_KEY_ID
        unset AWS_SECRET_ACCESS_KEY
        unset AWS_SESSION_TOKEN
        unset AWS_REGION
    else
        export AWS_ACCESS_KEY_ID=$(aws configure get ${profilename}.aws_access_key_id)
        export AWS_SECRET_ACCESS_KEY=$(aws configure get ${profilename}.aws_secret_access_key)
        export AWS_SESSION_TOKEN=$(aws configure get ${profilename}.aws_session_token)
        export AWS_REGION=$(aws configure get ${profilename}.aws_region)
    fi
}
alias awsall="_awsListAll"
alias awsp="_awsSwitchProfile"
alias awswho="aws configure list"
alias awsenv="_awsSetEnv"

eval "$(/opt/homebrew/bin/brew shellenv)"
