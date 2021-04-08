
## 導入環境、ツール
    + レイヤー１：
      + centOS7.6.1810
      + php7.2 , xdebug, xhprof
      + composer2.0
      + phing 2.16.4
    + レイヤー２：
      + java-11-openjdk-devel
      + Jenkins 2.277.1 lts
      + SSH
      + git 2.22
      + その他ツール
+ ## ローカル使用
  ```
    git clone <git repo>
    cd <repo folder>
    cd cd centos-base
    docker-compose build
    docker images // image の確認
    cd ../jen-centos76
    docker-compose build
    docker images
    docker-compose up -d
    docker ps // container の立ち上げ確認
    ssh -p 2222 root@localhost 
  ```
    ローカルのProxy設定必要な場合はカスタマイズで追加　　

+ ## AzureのAppService へ
  + (省略)
+ ## 立ち上げ後の設定
  + install時初期Adminパスワード：
    　ssh で初期パスワード取得
  + crumb issue protection configuration:
      Manage Jenkins -> Configure Global Security -> CSRF Protection: Enable proxy compatibility
      ![CSRF protection configuration](imgs/csrf%20protection%20configuration.png)
  + 追加プラグインのインストール：
    　Manage Jenkins -> Manage Plugins -> Available
      下記のプラグイン追加：
      + sonar-scanner 
      + gitlab authentication 
      + gitlab 
      + gitlab-branch-source 
      + groovy 
      + groovy-postbuild
      + HTML publisher (Optional: used for present HTML test report in Jenkins)
  + グローバル認証鍵の追加
      + gitLab でトークン作成（別途参考）
      + Manage Jenkins -> Manage Credentials -> System -> Global credentials (別途参考)
  + SSH で認証追加設定：
      + git 認証：
        $JENKINS_HOME/で.git-credentials ファイルを追加：
        ```
        su - jenkins
        vi .git-credentials
        git config --global credential.helper store
        ```

        .git-credentials:
        ```
        https://jenkins_user:xr5CFEAyqmmgjVYiGson@gitlab.xxxxx.org
        ```
        .gitconfig(自動生成):
        ```
        [credential]
        helper = store
        ```
        - .git-credentials はCredential作成時点自動作成される想定していますが,作成されていない場合は上記手動追加

      + composer 認証：
        $JENKINS_HOME/.config/composer/にauth.jsonを追加
        ```
        {
            "http-basic": {
                "gitlab.ddsdev.org": {
                    "username": "jenkins_user",
                    "password": "xr5CFEAyqmmgjVYiGson" //test passwd
                }
            }
        }
        ```







