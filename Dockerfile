FROM ubuntu:23.10
RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-11-jre-headless wget rlwrap cmake clang ninja-build pkg-config libgtk-3-dev

#Clojure
RUN curl -O https://download.clojure.org/install/linux-install-1.11.1.1347.sh
RUN chmod +x linux-install-1.11.1.1347.sh
RUN ./linux-install-1.11.1.1347.sh
RUN rm linux-install-1.11.1.1347.sh

RUN useradd -ms /bin/bash user
RUN mkdir /home/user/app
RUN chown user /home/user/app
WORKDIR /home/user
USER user

#Android SDK
RUN mkdir -p Android/sdk/cmdline-tools
ENV ANDROID_SDK_ROOT /home/user/Android/sdk
ENV ANDROID_HOME /home/user/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg
RUN wget -O cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
RUN unzip cmdline-tools.zip && rm cmdline-tools.zip
RUN mv cmdline-tools Android/sdk/cmdline-tools/latest
ENV PATH "$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
RUN yes | sdkmanager --licenses
RUN sdkmanager "build-tools;33.0.0" "patcher;v4" "platform-tools" "platforms;android-33" "sources;android-33" "system-images;android-33-ext4;google_apis_playstore;x86_64"
ENV PATH "$PATH:$ANDROID_HOME/platform-tools"
RUN printf "no" | avdmanager create avd --name device1 -k "system-images;android-33-ext4;google_apis_playstore;x86_64"

#Flutter SDK
RUN git clone -b master https://github.com/flutter/flutter.git
ENV PATH "$PATH:/home/user/flutter/bin"
RUN flutter upgrade
RUN flutter doctor --android-licenses
RUN flutter doctor

WORKDIR /home/user/app
COPY docker-deps.edn deps.edn

RUN clj -M:cljd init

# CMD ["flutter", "emulators", "--launch=device1", "&&", "clj", "-M:cljd", "flutter"]
# CMD ["clj", "-M:cljd", "flutter"]
