Vim�UnDo� �A ��������wD·���hzYk8���2����  I                  0   ,   0   0   +    ]���    _�       	             �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]��?     �   �   �          " => Load pathogen paths   """"""""""""""""""""""""""""""   /let s:vim_runtime = expand('<sfile>:p:h')."/.."   8call pathogen#infect(s:vim_runtime.'/sources_forked/{}')   <call pathogen#infect(s:vim_runtime.'/sources_non_forked/{}')   4call pathogen#infect(s:vim_runtime.'/my_plugins/{}')   call pathogen#helptags()5�_�                 	   �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]��@    �   �   �          """"""""""""""""""""""""""""""5�_�   	                n        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]���     �   n   q  K       �   n   p  J    5�_�                    p        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]��     �   o   p           5�_�                    p        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]��    �   o   p          .autocmd FileType * setlocal formatoptions-=cro5�_�                   x       ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]��<     �   w   y  J      " Disable arrow keys5�_�                    �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]���    �   �   �                      \ }�   �   �          &            \ 'colorscheme': 'wombat',�   �   �          let g:lightline = {�   �   �          set noshowmode5�_�                    �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]���    �   �   �                      "\ }�   �   �          '            "\ 'colorscheme': 'wombat',�   �   �          "let g:lightline = {�   �   �          "set noshowmode5�_�      %             �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]��s     �   �   �  J    5�_�      &   #       %   �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]���     �   �   �          !" Custom window position and size5�_�   %   '           &   �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]���     �   �   �          let g:NERDTreeWinSize=30   let g:NERDTreeWinPos = "left"5�_�   &   (           '   �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]���     �   �   �  H    �   �   �  H    5�_�   '   )           (   �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]���     �   �   �  J    5�_�   (   *           )   �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]���     �   �   �           5�_�   )   +           *   �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]���     �   �   �           5�_�   *   ,           +  C        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                      C          B           V        ]���    �  B  D          imap jj <Esc>5�_�   +   /           ,  C       ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                      C          B           V        ]���     �  B  D          imap jj <Esc>5�_�   ,   0   -       /  C       ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �          �   
       v       ]��      �  B  D          "imap jj <Esc>5�_�   /               0   �       ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �          �          v       ]��     �   �   �          +    "autocmd BufWinEnter ?* silent loadview5�_�   ,   .       /   -  C        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                      C          B           V        ]���     �  B  D          "imap jj <Esc>5�_�   -               .  C   	    ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                      C          B           V        ]���     �  B  D          imap jj <Esc>5�_�      $   !   %   #   �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]���     �   �   �        5�_�   #               $   �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]���     �   �   �  J    �   �   �  J      let g:NERDTreeWinSize=30   let g:NERDTreeWinPos = "left"5�_�      "       #   !   �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]���     �   �   �        5�_�   !               "   �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]���     �   �   �  I    �   �   �  I      let g:NERDTreeWinSize=30   let g:NERDTreeWinPos = "left"5�_�             !       �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]���     �   �   �        5�_�                    �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �          �          V   "    ]���     �   �   �  K       5�_�                   �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]��x     �   �   �        5�_�                     �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]��z     �   �   �  J    �   �   �  J      let g:NERDTreeWinSize=305�_�                  �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]��V     �   �   �        5�_�                   �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]��c     �   �   �        5�_�                     �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]��e     �   �   �  G    �   �   �  G      let g:NERDTreeWinSize=30   let g:NERDTreeWinPos = "left"5�_�                   �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]��Z     �   �   �        5�_�                     �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �           �           V        ]��[     �   �   �        5�_�                   �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]��     �   �   �        5�_�                     �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]��     �   �   �        5�_�                   m        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]��     �   m   n  J       5�_�                     o        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]��     �   o   p  K       5�_�   	                *        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]���     �   *   +  J       5�_�   	       
         *        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]���     �   *   +  J      "5�_�   	              
   -        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]���     �   ,   .  J       �   +   .  J      set showmatch 5�_�                    �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �          �          V       ]���     �   �   �        5�_�                    �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       \           i           V        ]���     �   �   �        5�_�                   \        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]��    �   [   ]          $"vnoremap $1 <esc>`>a)<esc>`<i(<esc>�   \   ^          $"vnoremap $2 <esc>`>a]<esc>`<i[<esc>�   ]   _          $"vnoremap $3 <esc>`>a}<esc>`<i{<esc>�   ^   `          $"vnoremap $$ <esc>`>a"<esc>`<i"<esc>�   _   a          $"vnoremap $q <esc>`>a'<esc>`<i'<esc>�   `   b          $"vnoremap $e <esc>`>a"<esc>`<i"<esc>�   a   c           �   b   d          1"" Map auto complete of (, ", ', [ in insert mode�   c   e          "inoremap $1 ()<esc>i�   d   f          "inoremap $2 []<esc>i�   e   g          "inoremap $3 {}<esc>i�   f   h          "inoremap $4 {<esc>o}<esc>O�   g   i          "inoremap $q ''<esc>i�   h   j          "inoremap $e ""<esc>i5�_�                   =        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]��1     �  =  >  J       5�_�                  =        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]��.     �  =  >  J       5�_�                   =        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                                                        ]��'     �  <  =  J      "5�_�                    �        ����    �                                                                                                           �                                               �                                                           �   
                   �                                                                       �          �          V       ]���     �   �   �  J      "5��