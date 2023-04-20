import json
import os
import re
import subprocess
import random

import boto3
from diffimg import diff
# import termcolor

photo_key_lookup = json.load(open("keys_to_ids.json"))
storage_key_lookup = json.load(open('storage_keys_to_ids.json'))
storage_name_lookup = json.load(open('storage_service_names.json'))

sess = boto3.Session()

s3 = sess.client('s3')


def download(bucket, key):
    if os.path.exists(f'/tmp/{bucket}/{key}'):
        return f'/tmp/{bucket}/{key}'
    os.makedirs(os.path.dirname(f'/tmp/{bucket}/{key}'), exist_ok=True)
    s3.download_file(
        Bucket=bucket,
        Key=key,
        Filename=f'/tmp/{bucket}/{key}'
    )
    return f'/tmp/{bucket}/{key}'

def main(event, context):
    # for f in os.listdir('/tmp')

        # assert 0

    lines = list(open('../../out.txt'))

    #
    # random.shuffle(lines)
    #
    for line in lines:
            print('\n- - -\n')
        # try:
            s3_obj = json.loads(line)
        # for record in event['Records']:
            # s3_obj = json.loads(record['Sns']['Message'])
            # s3_obj = {"Key": "miro/jpg_derivatives/C0077000/C0077196.jpg", "LastModified": "2018-02-26T15:36:51+00:00", "ETag": "\"2be70179a602a9949ff5af30f17d6c70\"", "Size": 2450368, "StorageClass": "DEEP_ARCHIVE"}

            if s3_obj["Size"] == 0:
                print(f'!!! skipping object, {s3_obj["Key"]} is empty')
                continue

            filename = os.path.basename(s3_obj["Key"])

            m = re.match(r"^(?P<id>C[0-9]{7}).*$", filename)

            if m is None:
                print(f'!!! no editorial photography ID found in {filename}')
                editorial_photography_id = None
                # return
            else:
                editorial_photography_id = m.group("id")

            if editorial_photography_id in {'C0146482', 'C0114175', 'C0135460'}:
                continue

            print(editorial_photography_id)

            for bucket, lookup, values in [
                (
                    "wellcomecollection-editorial-photography", photo_key_lookup,
                    photo_key_lookup.get(editorial_photography_id, []),

                ),
                (
                    "wellcomecollection-storage", storage_key_lookup,
                    storage_key_lookup.get(editorial_photography_id, [])
                ),
                ("wellcomecollection-storage", storage_name_lookup, storage_name_lookup.get(filename.split(".")[0], [])),
                ("wellcomecollection-storage", storage_name_lookup, storage_name_lookup.get(filename.split(".")[0].replace(' ', '_').replace('#', '_').replace('&', '_').replace('%', '_').replace("'", "_"), []))

            ]:

                for key in sorted(
                    values,
                    key=lambda k: len(os.path.commonprefix([os.path.basename(k), os.path.basename(s3_obj['Key'])])),
                    reverse=True
                ):
                    try:
                        h = s3.head_object(
                            Bucket=bucket,
                            Key=key,
                        )

                        print(bucket, key)

                        # from pprint import pprint; pprint(h)

                        if bucket == 'wellcomecollection-editorial-photography':
                            if 'Restore' not in h:
                                # print(termcolor.colored(f'Cannot compare to {key}, not restored from Glacier... ({s3_obj["Key"]})', 'blue'))
                                print(f'Cannot compare to {key}, not restored from Glacier... ({s3_obj["Key"]})')
                                continue
                            if h['Restore'] == 'ongoing-request="true"':
                                print(f'Waiting for {key} to restore... ({s3_obj["Key"]})')
                                continue

                        os.makedirs('/tmp/assets', exist_ok=True)
                        os.makedirs('/tmp/editorial-photography', exist_ok=True)

                        assets_filename = download(bucket="wellcomecollection-assets-workingstorage", key=s3_obj['Key'])
                        photography_filename = download(bucket=bucket, key=key)

                        # s3.download_file(
                        #     Bucket=bucket,
                        #     Key=key,
                        #     Filename=photography_filename
                        # )
                        #
                        # s3.download_file(
                        #     Bucket=,
                        #     Key=s3_obj["Key"],
                        #     Filename=assets_filename
                        # )

                        d = diff(photography_filename, assets_filename, delete_diff_file=True, ignore_alpha=True)

                        manually_approved = False

                        if d >= 0.021 and d < 0.1:
                            subprocess.check_call(['imgcat', assets_filename])
                            print('')
                            subprocess.check_call(['imgcat', photography_filename])
                            print('')
                            import click
                            manually_approved = click.confirm(f'Are these images the same? ({d})')

                        if d < 0.021 or manually_approved:
                            print(f'assets are the same; deleting {s3_obj["Key"]}')

                            sess.client('sqs').send_message(
                                QueueUrl=os.environ.get('QUEUE_URL', 'https://sqs.eu-west-1.amazonaws.com/760097843905/clean-up-wc-assets-workingstorage-miro'),
                                MessageBody=json.dumps({
                                    "s3_obj": s3_obj,
                                    "reason": f"This is visually identical to the image at s3://{bucket}/{key} ({d} / manually_approved = {manually_approved})"
                                })
                            )

                            s3.delete_object(Bucket="wellcomecollection-assets-workingstorage", Key=s3_obj['Key'])

                            # os.unlink(assets_filename)
                            # os.unlink(photography_filename)

                            break
                        else:
                            print(f"assets are different:\n\t{key}\n\t{s3_obj['Key']}\n\tdiff = {d}")

                    # os.unlink(assets_filename)
                    # os.unlink(photography_filename)
                    except Exception as e:
                        print(e)

if __name__ == '__main__':
    main(None, None)