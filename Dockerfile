ARG FUNCTION_DIR="/function"

FROM python:3.6-slim-buster as builderimage

ARG FUNCTION_DIR

RUN apt-get update && \
  apt-get install -y \
  g++ \
  make \
  cmake \
  unzip \
  libcurl4-openssl-dev

RUN mkdir -p ${FUNCTION_DIR}
COPY app/* ${FUNCTION_DIR}/

RUN pip install \
    --target ${FUNCTION_DIR} \
    awslambdaric \
    boto3 \
    numpy==1.19.1 \
    graphviz==0.8.4 \
    requests==2.24.0

# Note: replace with your own mxnet image or install the mxnet lib...
FROM m1l0/mxnet:v1.8.x-py3.6-cpu

ARG FUNCTION_DIR

WORKDIR ${FUNCTION_DIR}

COPY --from=builderimage ${FUNCTION_DIR} ${FUNCTION_DIR}

ENTRYPOINT ["python", "-m", "awslambdaric"]
CMD ["app.handler"]