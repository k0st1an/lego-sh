# legosh

A small script to automate the receipt of [Let’s Encrypt](https://letsencrypt.org) certificates using [lego](https://github.com/go-acme/lego).

- GitHub: https://github.com/k0st1an/legosh

## Usage
### Configs

`legosh` looks for configs in the `~/.legosh` directory. You can override this behavior using `LEGOSH_DIR`:

```sh
LEGOSH_DIR=/path lego.sh ...
```

The `env` file contains the variables needed for `lego` and `legosh` to work. Example:

```
LEGOSH_EMAIL="foobar@domain.com"
LEGOSH_RUN_HOOK="run_hook.sh"       # Optinal. The command must be in PATH or the full path to the command.
LEGOSH_RENEW_HOOK="renew_hook.sh"   # Optinal. The command must be in PATH or the full path to the command.
LEGOSH_DNS_PROVIDER="cloudflare"
export CLOUDFLARE_DNS_API_TOKEN="XXXX"
```

In the config `rewnew_cert.list` you can add domains to be renewed. Example:

```
domain.com
domain2.dev
_.domain2.dev
```

`_.domain2.dev` - more info [here](https://github.com/go-acme/lego/blob/d81507c126ce11c9197e94df2a4349c3b9799ef4/docs/content/usage/cli/Obtain-a-Certificate.md?plain=1#L38-L39).

> Certificate names should be used from the `Certificate Name` field of the `lego list` command.

### CLI

```sh
lego.sh help
```

```
Usage: lego.sh ...
ACTION:
  run domain[,domain...]      run lego to get certificate
  renew [domain[,domain...]]  renew certificate
  revoke domain[,domain...]   revoke certificate
  help                        show this help

Path to env file: /root/.legosh/env
Renew certs: /root/.legosh/renew_cert.list

Repository: https:/github.com/k0st1an/legosh
License: BSD 3-Clause
```

If in `env` there is an option `LEGOSH_RUN_HOOK` or `LEGOSH_RENEW_HOOK` and you need to temporarily disable the hook call, you can do it like this:

```sh
LEGOSH_NO_HOOK=true lego.sh run|renew
```

Or add `LEGOSH_NO_HOOK=true` to `env`.

## LICENSE

BSD 3-Clause
