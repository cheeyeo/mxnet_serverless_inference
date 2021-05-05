import boto3
import mxnet as mx
from mxnet import image
from mxnet import nd
from mxnet.gluon.model_zoo import vision as models
import os
import sys
import uuid
import json
from datetime import datetime


s3 = boto3.resource("s3")

# Output bucket
output_bucket = os.environ.get("OUTPUT_BUCKET")

# Download resource from resource bucket
resource_bucket = os.environ.get("RESOURCE_BUCKET")

# Lambda has no GPU support 
label_classes = "synset.txt"
model_params = "resnet50_v2.params"
label_file = "/tmp/{}".format(label_classes)
model_file = "/tmp/{}".format(model_params)
s3.Bucket(resource_bucket).download_file(label_classes, label_file)
s3.Bucket(resource_bucket).download_file(model_params, model_file)

model_ctx = mx.cpu()
net = models.resnet50_v2(pretrained=False)
net.load_parameters(model_file, ctx=model_ctx)
net.hybridize()

with open(label_file, "r") as f:
    labels = [' '.join(l.split()[1:]) for l in f]

def transform_image(img_path):
    img = image.imread(img_path)
    data = image.resize_short(img, 256)
    data, _ = image.center_crop(data, (224, 224))
    data = data.transpose((2, 0, 1)).expand_dims(axis=0)
    rgb_mean = nd.array([0.485, 0.456, 0.406]).reshape((1,3,1,1))
    rgb_std = nd.array([0.229, 0.224, 0.225]).reshape((1,3,1,1))
    data = (data.astype("float32") / 255 - rgb_mean) / rgb_std
    return data

def handler(event, context):
    print(event)
    print(context)

    # If we set a timer to ping this function we need to return 200..
    if event.get("source") == "aws.events" and event.get("detail-type") == "Scheduled Event":
        return {
            "statusCode": 200,
            "body": json.dumps("PONG")
        }

    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        img_path = "/tmp/{}".format(key)
        print("Downloading image from path: {}".format(img_path))
        s3.Bucket(bucket).download_file(key, img_path)

        # transform data and perform inference
        data = transform_image(img_path)
        predict = net(data)
        idx = predict.topk(k=1)[0]
        idx = int(idx.asscalar())
        os.remove(img_path)

        time = datetime.now().strftime("%d%m%Y-%H:%M:%S")
        file_name = "{}_{}.txt".format(key, time)
        content = labels[idx]
        print("Predicted Content: {}".format(content))
        s3.Object(output_bucket, file_name).put(Body=content)

    return {
        "statusCode": 200,
        "body": json.dumps("Successfully classified image...")
    }