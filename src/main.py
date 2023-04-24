def run_function(*args, **kwargs):
    print("hello world!")
    print(f"args = {args!r}")
    print(f"kwargs = {kwargs!r}")


def main(event, context):
    run_function(event=event, context=context)


if __name__ == "__main__":
    main(None, None)
