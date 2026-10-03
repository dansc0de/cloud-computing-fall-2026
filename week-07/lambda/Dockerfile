# AWS's Lambda base image: Python 3.14 plus the runtime interface client that
# talks to the Lambda service. There is no web server and no port to EXPOSE.
FROM public.ecr.aws/lambda/python:3.14

# ${LAMBDA_TASK_ROOT} is /var/task, where the runtime looks for your code.
COPY src/handler.py ${LAMBDA_TASK_ROOT}/

# Not a process to start: the handler to call, as file.function.
CMD ["handler.handler"]
