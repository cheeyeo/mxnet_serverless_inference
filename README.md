## MXNet Serverless example

Running mxnet container on lambda to create a streaming inference pipeline...

The image has to be uploaded to ECR before it can be used...


### Running

The lambda function is created via a docker container containing the AWS Lambda python RIC.

A multi stage build whereby we build the RIC client with the app dependencies and package them into a `function` directory together with the app files

The `function` directory is then copied into the final image which contains the ML lib in this case MXNet you want to run the lambda function on. The source image can either be from ECR or dockerhub

The final image needs to be pushed to ECR as within the lambda console you can only select images hosted on ECR...

To test it, you would need to create an input bucket to upload the test images into. The predictions are written into a target bucket

We can replace the target bucket with a database such as DynamoDB ...

### Testing it locally

https://github.com/aws/aws-lambda-runtime-interface-emulator




### Docker compatibility

https://github.com/aws/aws-lambda-python-runtime-interface-client

Custom images need to implement the above in order to make docker image compliant...


### IAM Role

 Roles → Create role → Lambda

Need an IAM role with following policies/permissions:
* AmazonS3FullAccess
* AmazonLambdaBasicExecutionRole
* CloudWatchEventsFullAccess

Add a trigger to lambda
The last step is to add an S3 “All object create events” trigger to the Lambda function. Go to the AWS Lambda management console → Functions → Select the function we just created → add trigger → select S3 → specify input_bucket for bucket name→ specify “All object create events” for Event type.

### Ref:

* https://acloudguru.com/blog/engineering/packaging-aws-lambda-functions-as-container-images

* https://medium.com/apache-mxnet/streaming-inference-pipeline-deploying-mxnet-model-on-aws-lambda-7ce6bc8f4cc8

* https://github.com/waytrue17/MXNet-on-Lambda/blob/master/lambda_function.py

### Notes

* Default vol size for docker container in lambda is 10gb...

* Lambda still has /tmp folder size of 512 mb

* When the Lambda function is running it has automatic timeout of 3 secs

  Need to increase both timeout and mem to 1024 mb and 15 secs

  How do we do a warm start?

  https://read.acloud.guru/how-to-keep-your-lambda-functions-warm-9d7e1aa6e2f0

  Set up cloudwatch timer event and ping the lambda function every minute...

* If model size is too big might need to use a compressed runtime like Neo: https://github.com/neo-ai/neo-ai-dlr or to use Lambda with EBS/EFS