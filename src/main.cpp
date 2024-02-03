#include <iostream>

#include "decrypt.h"

#include <cstdio>
#include <cstring>
#include <cstdlib>

int main(int argc, char *argv[]){
  char *encrypt_text = "poojt1296bud3qd14z8cs3j6w836qn40n%202552u%43r0v7x84wa6531$410qt30ulnp00q4vil1ajb59pq65ik5t8b6az41!u{1979242tg1o597ntf}ucw9i2qt376643vf7j5r4mpmi20163bqa5n)o~9k03i$zu200k12m2?0er95065bu9v%8w11idf7216643gw7)qj61l01w>0hcf283li0{kuf'7319mu8kw0u1664}qhccfqi(eq28";
  char decrypt_text[128];
  decrypt_key(encrypt_text, decrypt_text, strlen(encrypt_text));
  printf("decrypt_text : %s\n", decrypt_text);
}
