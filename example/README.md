hook-corona-sdk example
===

Usage example of [hook](https://github.com/doubleleft/hook) services inside a
corona-sdk application.

How to run
---

1. Clone [hook-corona-sdk](https://github.com/doubleleft/hook-corona-sdk.git).
2. Download and install [hook](https://github.com/doubleleft/hook#installation) backend.
3. Make sure that `hook server` is running.
4. Create a new hook application inside `example` directory.
5. Open the `example` app with Corona Simulator.

Step by step:

```bash
# create a directory for all stuff needed
mkdir hook-corona-stuff
cd hook-corona-stuff

# clone hook-corona-sdk and install hook backend server
git clone https://github.com/doubleleft/hook-corona-sdk.git
curl -sSL https://raw.githubusercontent.com/doubleleft/hook/master/scripts/install.sh | bash

# start backend server
cd hook
hook server # This will lock your terminal, you'll need to open another tab to continue.

# create a new hook application inside hook-corona-sdk/example directory
cd hook-corona-stuff
cd hook-corona-sdk/example
hook app:new hook-corona-sdk
```
