# Latest version of python3
FROM python
RUN pip install -U pip
# RUN pip install ansible
ADD . /root/.docker_ansible
# WORKDIR /root
RUN pip install -r /root/.docker_ansible/requirements.txt
CMD ["bash"]
