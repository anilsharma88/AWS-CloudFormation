#!/bin/bash

set -e # Exit immediately if a command returns error

# Variables
STACK_NAME='RootStack'
ROOT_TEMPLATE='root-template.yaml'
OUTPUT_TEMPLATE='packaged-root-template.yaml'
TEMPLATE_BUCKET='my-cf-templates-bucket'
REGION='eu-west-1'
WEB_SERVER_IMAGE='ami-0bb3fad3c0286ebd5'
WEBSITE_BUCKET='my-website-source'

# Package the nested templates and produce an output template from the root template
aws cloudformation package \
    --template $ROOT_TEMPLATE \
    --s3-bucket $TEMPLATE_BUCKET \
    --output-template-file $OUTPUT_TEMPLATE \
    --region $REGION

# Deploy the output template of the package command
aws cloudformation deploy \
    --template-file $OUTPUT_TEMPLATE \
    --stack-name $STACK_NAME \
    --parameter-overrides WebServerImage=$WEB_SERVER_IMAGE WebsiteBucket=$WEBSITE_BUCKET \
    --capabilities CAPABILITY_IAM \
    --region $REGION