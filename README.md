# RISO-1.0
Recuperação de Imagem de Sistema Operacional

O RISO (Recuperação de Imagem de Sistema Operacional) é um sistema que recupera imagens em múltiplas máquinas simultaneamente. Para isso, ele utiliza a tecnologia Torrent pra transmitir as imagens do servidor para os clientes.

Todo o sistema é baseado em distribuição Debian 8.2 e, portanto, não há garantia de funcionamento em outras distribuições.

O RISO foi feito para recuperar até 2 sistemas ao mesmo tempo, 1 Linux e 1 Windows.

INSTALAÇÃO:

Dentro da pasta do RISO digite './install.sh'

UTILIZAÇÃO:

Primeiro, deve-se criar a máquina matriz, que servirá também como servidor. O particionamento deve ser feito de maneira que pelo menos metade do disco seja reservado para um sistema de recuperação (Debian 8.2) onde deve ser instalado o sistema RISO. A outra metade deve ser dividida da maneira que se considerar mais adequado, entre 1 sistema Linux, 1 Windows e uma partição SWAP. O GRUB a ser utilizado deve ser o da partição de recuperação.
