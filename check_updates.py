import docker
import sys

client = docker.from_env()
local_images = []

def update_images():
    for image in client.images.list():
        try:
            if "/" in image.attrs['RepoTags'][0]:
                client.images.pull(image.attrs['RepoTags'][0])
        except:
            pass

def update_image_list():
    for image in client.images.list():
        try:
            local_images.append(image.attrs['Id'])
        except:
            pass

def needs_update():
    for container in client.containers.list():
        if container.attrs['Image'] not in local_images:
            return sys.exit(1)
    return sys.exit(0)
      

if __name__ == "__main__":
    update_images()
    update_image_list()
    needs_update()
