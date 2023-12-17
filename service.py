import docker
import subprocess
from pprint import pprint
import time

client = docker.from_env()


def make_reset():
    proc = subprocess.Popen('make reset', shell=True, executable="/bin/bash", cwd = '/home/dave/src/docker-media-center', stdout=subprocess.PIPE)

    while True:
        line = proc.stdout.readline()
        if not line:
            break
        else: 
            print(line)

def check_containers():
    while True:
        time.sleep(600)
        rebuild = False
        count = 0
        for container in client.containers.list(all=True):        
            if 'com.docker.compose.project.working_dir' in container.attrs['Config']['Labels']:
                if container.attrs['Config']['Labels']['com.docker.compose.project.working_dir'] == "/home/dave/src/docker-media-center":
                    pprint(container.attrs['Name']) 
                    if container.attrs['State']['Status'] != 'running': 
                        pprint(container.attrs['State']['Status'])    
                        pprint(container.attrs['Config']['Labels']['com.docker.compose.project.working_dir'])
                        rebuild = True
                    else:
                        count += 1
        if rebuild or count != 12:                
            make_reset()


if __name__ == "__main__":
    check_containers()