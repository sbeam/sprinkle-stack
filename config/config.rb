ENVIRONMENT = :production

CONFIG = {
  :production => {
    :apps => [
      {
        :ip => '96.126.110.14',
        :ram => 500,
      },
    ],
    :db => {
      :ip => '96.126.110.14',
      :ram => 500
    }
  }
}

USER_TO_ADD = 'deploy'
