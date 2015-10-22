include nginx
include ruby

### explicitly stated module loading sequence by puppet
Class['nginx']->Class['ruby']
