# syntax=docker.io/docker/dockerfile:1.4
# FROM cartesi/toolchain:0.11.0 as dapp-build
# FROM toolchain-python as dapp-build
FROM cartesi/toolchain-python as dapp-build

WORKDIR /opt/cartesi/dapp

SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y cmake

COPY . .

RUN source compiler-envs.sh && cd 3rdparty && make geos

RUN <<EOF 
pip3.10 install crossenv 
python3.10 -m crossenv $(which python3) .env 
. ./.env/bin/activate 
pip install -r requirements.txt 
EOF

# RUN <<EOF 
# . ./.env/bin/activate 
# source compiler-envs.sh
# cd 3rdparty && make numpy
# EOF

RUN <<EOF 
. ./.env/bin/activate 
source compiler-envs.sh
CXXFLAGS="${CXXFLAGS} -I${ROOT_DIR}/3rdparty/glibc/include -I${ROOT_DIR}/3rdparty/geos/include" \
CFLAGS="${CFLAGS} -I${ROOT_DIR}/3rdparty/glibc/include -I${ROOT_DIR}/3rdparty/geos/include" \
LDFLAGS="${LDFLAGS} -L${ROOT_DIR}/3rdparty/glibc/lib -L${ROOT_DIR}/3rdparty/geos/lib" \
GEOS_CONFIG="3rdparty/geos-dist/bin/geos-config" && \
pip3.10 install shapely==1.5.9 -vvv --no-binary shapely
EOF

RUN source compiler-envs.sh && cd 3rdparty && make openssl

# RUN <<EOF 
# . ./.env/bin/activate 
# source compiler-envs.sh
# CXXFLAGS="${CXXFLAGS} -I${ROOT_DIR}/3rdparty/openssl/include" CFLAGS="${CFLAGS} -I${ROOT_DIR}/3rdparty/openssl/include" LDFLAGS="${LDFLAGS} -L${ROOT_DIR}/3rdparty/openssl/lib" && \
# pip3.10 install -vvv --no-binary opencv-python opencv-python==4.6.0.66 --global-option="${CFLAGS}" --global-option="${LDFLAGS}"
# EOF

# RUN . ./.env/bin/activate && cd 3rdparty && make opencv

# RUN [ -d .env ] && rm -rf .env

# export PATH=3rdparty/geos-dist/bin:$PATH
# export GEOS_INCLUDE_PATH=3rdparty/geos-dist/include
# export GEOS_LIBRARY_PATH=3rdparty/geos-dist/lib
# export LD_LIBRARY_PATH=3rdparty/geos-dist/lib/:$LD_LIBRARY_PATH

# ENV GEOS_INCLUDE_PATH=3rdparty/geos-dist/include
# ENV GEOS_LIBRARY_PATH=3rdparty/geos-dist/lib

# RUN GEOS_CONFIG="3rdparty/geos-dist/bin/geos-config"  \
# pip3 install crossenv && \
# python3 -m crossenv $(which python3) .env && \
# . ./.env/bin/activate && \
# pip install -r requirements.txt 

# RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get install -y jq
# RUN ./docker/build-dapp-fs.sh docker/default.json dapp.json dapp.ext2

# RUN cat docker/dependencies | xargs wget
# RUN sha1sum -c docker/shasumfile

# FROM server-manager as machine-test
# WORKDIR /opt/cartesi/dapp

# # copy dapp ext2 from stage 1
# COPY --from=dapp-build /opt/cartesi/dapp .

# CMD ["run-machine-console.sh"]


# target "dapp" {
#   contexts = {
#     toolchain-python = "target:toolchain-python"
#   }
# }
