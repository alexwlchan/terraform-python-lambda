<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">

    <title>${name}</title>

    <style>
      body {
        max-width: 800px;
        margin-left:  auto;
        margin-right: auto;
        background: #fff9e6;
        font-family: -apple-system, sans-serif;
        line-height: 1.5em;
      }

      main {
        background: white;
        padding: 1em 2em;
        border-radius: 10px;
      }

      a {
        font-weight: bold;
      }
    </style>
  </head>
  <body>
    <main>
      <h1>${name}</h1>

      <h3>Your new function has been created!</h3>

      <p>
        You can see your new function <a href="https://${region}.console.aws.amazon.com/lambda/home?region=${region}#/functions/${name}?tab=code">in the AWS Console</a>.
      </p>

      <p>
        You can send messages to your function at the following SNS topic:
      </p>

      <ul>
        <li><strong>arn:</strong> ${topic_arn}</li>
        <li><strong>name:</strong> ${topic_name}</li>
      </ul>

      <p>
        You can retrieve the output of your function at the following SQS topic:
      </p>

      <ul>
        <li><strong>url:</strong> ${queue_url}</li>
        <li><strong>arn:</strong> ${queue_arn}</li>
        <li><strong>name:</strong> ${queue_name}</li>
      </ul>

      <p>
        You can see logs from your function <a href="https://${region}.console.aws.amazon.com/cloudwatch/home?region=eu-west-1#logsV2:log-groups/log-group/${log_group_name}">in the CloudWatch console</a>.
      </p>
    </main>
  </body>
</html>
