#!/bin/bash

set -e

# Variables
STACK_NAME='DatabaseStack'
TEMPLATE_FILE='database-template.yaml'
REGION='eu-west-1'

aws cloudformation deploy \
    --template-file $TEMPLATE_FILE \
    --stack-name $STACK_NAME \
    --region $REGION
