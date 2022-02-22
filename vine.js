
 window.open("https://vinelink.vineapps.com/search/CA/Person");
 var foundButton = 0;
 if ( document.querySelector('#vl-menu-options-sign-in-button')){
      document.querySelector('#vl-menu-options-sign-in-button').click();
      foundButton = 1;
 }
 if  ( foundButton === 1){ 
    if ( document.querySelector('#mat-input-0')){
         document.querySelector('#mat-input-0').value = 'jozefn777';
         document.querySelector('#mat-input-1').value = 'BezelcanopyCar1b';
         document.querySelector('#v-1-login-btn').click();
    }
 }


