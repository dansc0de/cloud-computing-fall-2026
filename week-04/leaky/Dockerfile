# DO NOT copy this pattern. It demonstrates that deleting a file in a
# later layer does not remove it from the image.
FROM alpine
COPY fake-secret.txt /fake-secret.txt
RUN rm /fake-secret.txt
CMD ["ls", "/"]
