# Condenser

Condenser is the react.js web interface to [Blurt](https://gitlab.com/blurt/blurt).

### Changelog

Please update the changelog with every change that you make to condenser.

#### Quick Start: Run your own Blurt front end

To bring up a running container fit for production, it's as simple as this:

```bash
export CHICKEN=$(base64 --wrap=0 /dev/urandom | head -c 64)
echo $CHICKEN
docker run -it -p 8080:8080 -e SDC_SESSION_SECRETKEY=$CHICKEN registry.gitlab.com/blurt/blurt/condenser
```
Or, to run it on an ARM-based computer such as a Raspberry Pi, use this Docker command instead:

```bash
docker run -it -p 8080:8080 -e SDC_SESSION_SECRETKEY=$CHICKEN registry.gitlab.com/blurt/blurt/condenser-arm64
```

NB: Make sure that you record $CHICKEN somewhere safe. It should remain consistent.

One way you can do that is by storing it in a file that you can source whenever you update your Condenser.

First, generate the key like before:
```bash
export CHICKEN=$(base64 --wrap=0 /dev/urandom | head -c 64)
```
Then print out the key:
```
echo $CHICKEN
```
You will get an output similar to this:
```bash
X7WdZOFjSBWvnkbDRVrKtsN/xbPJ2V+xmgWtNpcWhzSX4qZFUyNqvROBK32V6zoT
```
Then copy that string and make a file like this from your home directory:
```bash
touch .chicken
nano .chicken
```
In that file put in the key that you just generated, like this:
```
export CHICKEN=X7WdZOFjSBWvnkbDRVrKtsN/xbPJ2V+xmgWtNpcWhzSX4qZFUyNqvROBK32V6zoT
```
Then do `Ctrl + o` and `Ctrl + x` to save and exit.

The next time you want to relaunch Condenser, you can just do:
```bash
source .chicken
docker run -it -p 8080:8080 -e SDC_SESSION_SECRETKEY=$CHICKEN registry.gitlab.com/blurt/blurt/condenser
```

If you would like to modify, build, and run condenser using docker, it's as
simple as pulling in the gitlab repo and issuing one command to build it,
like this:

```bash
apt update
apt upgrade
apt install git
curl -s https://get.docker.com | bash
git clone https://gitlab.com/blurt/blurt.git
cd blurt/ui/condenser
docker build . -t="myname/condenser:mybranch"
docker run -it -p 8080:8080 -e SDC_SESSION_SECRETKEY=$CHICKEN myname/condenser:mybranch
```

By default you will be connected to public RPC node. This is actually on the real blockchain and
you would use your regular account name and credentials to login - there is
not an official separate testnet at this time. If you intend to run a
full-fledged site relying on your own, we recommend running
`blurtd` locally instead
[https://gitlab.com/blurt/blurt](https://gitlab.com/blurt/blurt).

## Geting Set Up

#### NVM

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
```

#### Install and build

```bash
apt update
apt upgrade
apt install git
git clone https://gitlab.com/blurt/blurt.git
cd blurt/ui/condenser
mkdir tmp
nvm install 16.5
npm i -g yarn
yarn install
yarn run build
```
N.B.: before you start Condenser, you will need to set the environment variable `SDC_SESSION_SECRETKEY` to a string of random characters with a minimum lenght of 32 bytes.

You can generate one with one of the following methods:

In a Linux terminal:
```bash
base64 --wrap=0 /dev/urandom | head -c 32
```

In nodejs:
```js
node
> crypto.randomBytes(32).toString('base64')
> .exit
```

To run Condenser in production mode, run:
```bash
yarn run production
```

When launching condenser in production mode it will automatically use 1
process per available core. You will be able to access the front-end at
http://localhost:8080 by default.

To run Condenser in development mode, run:
```bash
yarn run start
```

It will take longer to start in this mode because it needs to
build and start the webpack-dev-server.


After you've done your dev work, push to a branch. CI will test the build. If it builds, merge to dev and you'll have a docker container at registry.gitlab.com/blurt/blurt/condenser:dev containing your latest work.

#### Debugging SSR code

`yarn debug` will build a development version of the codebase and then start the
local server with `--inspect-brk` so that you can connect a debugging client.
You can use Chromium to connect by finding the remote client at
`chrome://inspect/#devices`.

#### Configuration

The intention is to configure condenser using environment variables. You
can see the names of all of the available configuration environment
variables in `config/custom-environment-variables.json`. Default values are
stored in `config/defaults.json`.

Keep in mind environment variables only exist in your active session, so if
you wish to save them for later use you can put them all in a file and
`source` them in.

If you'd like to statically configure condenser without variables you can
edit the settings directly in `config/production.json`. If you're running
in development mode, copy `config/production.json` to `config/dev.json`
with `cp config/production.json config/dev.json` and adjust settings in
`dev.json`.

If you're intending to run condenser in a production environment one
configuration option that you will definitely want to edit is
`server_session_secret` which can be set by the environment variable
`SDC_SESSION_SECRETKEY`. To generate a new value for this setting, you can
do this:

```bash
base64 --wrap=0 /dev/urandom | head -c 32
```

## Style Guides For Submitting Pull Requests

### File naming and location

-   Prefer CamelCase js and jsx file names
-   Prefer lower case one word directory names
-   Keep stylesheet files close to components
-   Component's stylesheet file name should match component name

#### Js & Jsx

We use [prettier](https://github.com/prettier/prettier) to autofromat the
code, with [this configuration](.prettierrc). Run `yarn run fmt` to format
everything in `src/`, or `yarn exec -- prettier --config .prettierrc --write src/whatever/file.js` for a specific file.

#### CSS & SCSS

If a component requires a css rule, please use its uppercase name for the
class, e.g. "Header" class for the header's root div. We adhere to BEM
methodology with exception for Foundation classes, here is an example for
the Header component:

```html
<!-- Block -->
<ul class="Header">
    ...
    <!-- Element -->
    <li class="Header__menu-item">Menu Item 1</li>
    <!-- Element with modifier -->
    <li class="Header__menu-item--selected">Element with modifier</li>
</ul>
```

## Storybook

`yarn run storybook`

## Testing

### Run test suite

`yarn test`

will run `jest`

### Test endpoints offline

If you want to test a server-side rendered page without using the network, do this:

```
yarn build
OFFLINE_SSR_TEST=true NODE_ENV=production node --prof lib/server/index.js
```

This will read data from the blobs in `api_mockdata` directory. If you want to use another set of mock data, create a similar directory to that one and add an argument `OFFLINE_SSR_TEST_DATA_DIR` pointing to your new directory.

### Run blackbox tests using nightwatch

To run a Selenium test suite, start the condenser docker image with a name `condenser` (like `docker run --name condenser -itp 8080:8080 blurt/condenser:latest`) and then run the blackboxtest image attached to the condneser image's network:

```
docker build -t=blurt/condenser-blackboxtest blackboxtest/
docker run --network container:condenser blurt/condenser-blackboxtest:latest

```

## Issues

To report a non-critical issue, please file an issue on this GitHub project.

If you find a security issue please report details to: security@blurt.foundation

We will evaluate the risk and make a patch available before filing the issue.
