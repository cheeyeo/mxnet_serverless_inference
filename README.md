## MXNet Serverless example

Running MXNet container on lambda to create a streaming inference pipeline.

This is based on the following article:
https://medium.com/apache-mxnet/streaming-inference-pipeline-deploying-mxnet-model-on-aws-lambda-7ce6bc8f4cc8


### Running

Create the initial resources:
```
make setup
```

Upload the model's resources into the resource bucket:
```
make upload-resource
```

To make a prediction, assuming your images are in `examples` sub-dir:
```
make predictions
```

To view the results of the predictions, download the content of the target bucket:
```
make download-output
```

### Docker compatibility

To enable your lambda function to run within a docker container in lambda, your function need to be run by the AWS Lambda RIC:

https://github.com/aws/aws-lambda-python-runtime-interface-client

The lambda function is created via a docker container containing the AWS Lambda python RIC.

A multi stage build whereby we build the RIC client with the app dependencies and package them into a `function` directory together with the app files

The `function` directory is then copied into the final image which contains the ML lib in this case MXNet you want to run the lambda function on.

The final image needs to be pushed to ECR as within the lambda console you can only select images hosted on ECR.


### Testing it locally

Left as exercise to reader:

https://github.com/aws/aws-lambda-runtime-interface-emulator

## License
Licensed under an MIT license.