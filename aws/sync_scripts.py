import boto3
import sys
import os

def boto_folder(local_directory, bucket, destination, profile):
    """
    Arguments:
        * local_directory: local folder to upload
        * bucket: name of base bucket to upload to
        * destination: folder in bucket to upload to (should include original folder name)
            format: "folder/folder2/.../"
        * profile: aws cli profile to use for authentication
    """
    # get an access token, local (from) directory, and S3 (to) directory
    # from the command-line


    sesh = boto3.session.Session(profile_name='ipsos')
    client = sesh.client('s3')

    # enumerate local files recursively
    for root, dirs, files in os.walk(local_directory):

        for filename in files:
            print(filename)

            # construct the full local path
            local_path = os.path.join(root, filename)

            # construct the full Dropbox path
            relative_path = os.path.relpath(local_path, local_directory)
            s3_path = os.path.join(destination, relative_path)

            # relative_path = os.path.relpath(os.path.join(root, filename))

            print('Searching "%s" in "%s"' % (s3_path, bucket))

            print("Uploading %s..." % s3_path)
            client.upload_file(local_path, bucket, s3_path)

if __name__ == '__main__':
    boto_folder(local_directory = f"/Users/davidvandijcke/Dropbox (University of Michigan)/ipsos/data/code/s3/scripts/", 
                bucket = "ipsos-dvd", destination = "scripts/", profile = "ipsos")