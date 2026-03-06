# Pants + MITM Proxy Reproduction

Reproduction environment to investigate pants failing to download files when a MITM proxy is intercepting traffic.

## Setup

1. Ensure mitmproxy is installed (`brew install mitmproxy`)
2. Run `./scripts/setup-cert.sh` to generate and trust the mitmproxy CA cert

## Usage

**Terminal 1:** Start the proxy
```bash
./scripts/start-proxy.sh
```

**Terminal 2:** Run pants (will download ruff linter)
```bash
./scripts/run-pants.sh lint ::
```

To run without proxy CA certs (for comparison):
```bash
./scripts/run-pants.sh --no-proxy lint ::
```

## Error

```
23:01:30.74 [DEBUG] Downloading https://github.com/astral-sh/ruff/releases/download/0.13.0/ruff-aarch64-apple-darwin.tar.gz (attempt #1)
23:01:30.81 [DEBUG] Error while downloading https://github.com/astral-sh/ruff/releases/download/0.13.0/ruff-aarch64-apple-darwin.tar.gz: Error downloading file: error sending request for url (https://github.com/astral-sh/ruff/releases/download/0.13.0/ruff-aarch64-apple-darwin.tar.gz) (retryable)
23:01:30.89 [DEBUG] Downloading https://github.com/astral-sh/ruff/releases/download/0.13.0/ruff-aarch64-apple-darwin.tar.gz (attempt #2)
23:01:30.94 [DEBUG] Error while downloading https://github.com/astral-sh/ruff/releases/download/0.13.0/ruff-aarch64-apple-darwin.tar.gz: Error downloading file: error sending request for url (https://github.com/astral-sh/ruff/releases/download/0.13.0/ruff-aarch64-apple-darwin.tar.gz) (retryable)
23:01:30.96 [DEBUG] Downloading https://github.com/astral-sh/ruff/releases/download/0.13.0/ruff-aarch64-apple-darwin.tar.gz (attempt #3)
23:01:31.01 [DEBUG] Error while downloading https://github.com/astral-sh/ruff/releases/download/0.13.0/ruff-aarch64-apple-darwin.tar.gz: Error downloading file: error sending request for url (https://github.com/astral-sh/ruff/releases/download/0.13.0/ruff-aarch64-apple-darwin.tar.gz) (retryable)
23:01:31.02 [DEBUG] Downloading https://github.com/astral-sh/ruff/releases/download/0.13.0/ruff-aarch64-apple-darwin.tar.gz (attempt #4)
23:01:31.07 [DEBUG] Error while downloading https://github.com/astral-sh/ruff/releases/download/0.13.0/ruff-aarch64-apple-darwin.tar.gz: Error downloading file: error sending request for url (https://github.com/astral-sh/ruff/releases/download/0.13.0/ruff-aarch64-apple-darwin.tar.gz) (retryable)
23:01:31.07 [DEBUG] Completed: Downloading: https://github.com/astral-sh/ruff/releases/download/0.13.0/ruff-aarch64-apple-darwin.tar.gz (11.54 MB)
23:01:31.07 [DEBUG] Completed: pants.core.util_rules.external_tool.download_external_tool
23:01:31.07 [DEBUG] Completed: Lint with `ruff check`
23:01:31.08 [DEBUG] Completed: `lint` goal
23:01:31.08 [DEBUG] computed 1 nodes in 0.345816 seconds. there are 127 total nodes.
23:01:31.08 [ERROR] 1 Exception encountered:

Engine traceback:
  in `lint` goal

IntrinsicError: Error downloading file: error sending request for url (https://github.com/astral-sh/ruff/releases/download/0.13.0/ruff-aarch64-apple-darwin.tar.gz)
```

mitmproxy reports
```
Client TLS handshake failed. The client does not trust the proxy's certificate for github.com (tlsv1 alert unknown ca)
```

Suggesting that the Rust code in pants isn't handling the SSL_CERT_FILE var and failing TLS validation. 


## What's happening

- `--mode local` makes mitmproxy intercept traffic at the OS level using pf (no proxy env vars needed)
- `REQUESTS_CA_BUNDLE` and `SSL_CERT_FILE` tell Python to trust the mitmproxy CA
- Fresh temp cache dirs ensure no cached artifacts interfere
- `-ldebug --no-pantsd` enables verbose logging with a fresh process each run
