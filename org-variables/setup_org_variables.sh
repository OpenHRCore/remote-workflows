#!/bin/bash

# setup_org_variables.sh

# Help message
show_help() {
    echo "Usage: $0 -t <github_token> -o <organization_name>"
    echo
    echo "Options:"
    echo "  -t    GitHub personal access token with org admin permissions"
    echo "  -o    GitHub organization name"
    echo "  -h    Show this help message"
    exit 1
}

# Parse command line arguments
while getopts "t:o:h" opt; do
    case $opt in
        t)
            GITHUB_TOKEN=$OPTARG
            ;;
        o)
            GITHUB_ORG=$OPTARG
            ;;
        h)
            show_help
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            show_help
            ;;
    esac
done

# Check if required arguments are provided
if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_ORG" ]; then
    echo "Error: Both GitHub token and organization name are required."
    show_help
fi

# Ensure gh cli is authenticated
export GH_TOKEN=$GITHUB_TOKEN

echo "Setting up Organization Variables for $GITHUB_ORG"
echo "Adding CI/CD variables..."

if [ ! -f "cicd-variables.json" ]; then
    echo "cicd-variables.json not found. Please ensure the file exists in the current directory."
    exit 1
fi

# Function to check if a variable exists
check_variable() {
    local key=$1
    gh api -X GET "orgs/${GITHUB_ORG}/actions/variables/${key}" --silent && return 0 || return 1
}

# Function to create a new variable
create_variable() {
    local key=$1
    local value=$2
    echo "Creating variable $key"
    if gh api -X POST "orgs/${GITHUB_ORG}/actions/variables" \
        -f name="$key" \
        -f value="$value" \
        -f visibility="all" >/dev/null 2>&1; then
        echo "✅ Variable $key created successfully"
    else
        echo "❌ Failed to create variable $key"
        return 1
    fi
}

# Function to update an existing variable
update_variable() {
    local key=$1
    local value=$2
    echo "Updating variable $key"
    if gh api -X PATCH "orgs/${GITHUB_ORG}/actions/variables/${key}" \
        -f name="$key" \
        -f value="$value" \
        -f visibility="all" >/dev/null 2>&1; then
        echo "✅ Variable $key updated successfully"
    else
        echo "❌ Failed to update variable $key"
        return 1
    fi
}

# Process each key-value pair in the JSON file
for key in $(jq -c 'keys' cicd-variables.json | jq -r '.[]'); do
    value=$(jq -r ".$key" cicd-variables.json)
    echo "Processing key: $key"
    
    if check_variable "$key"; then
        update_variable "$key" "$value"
    else
        create_variable "$key" "$value"
    fi
    echo
done

echo "Organization variables setup completed!"
