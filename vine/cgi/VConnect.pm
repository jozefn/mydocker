package VConnect;

use Selenium::Chrome;
use JSON;
use Data::Dumper;

sub new {
    my $class = shift;
    my $args = shift;
    my $search_value = $args->{search_value} || "";
    my $user = $args->{user} || "";
    my $password = $args->{password} || "";
    my $drive = build_driver();
    my $png_cnt = 0;
    my $file_cnt = 0;
    my $self = {
        _user => $user,
        _password => $password,
        _driver => $driver,
        _png_cnt => $png_cnt,
        _file_cnt => $file_cnt,
        _search_value => $search_value,
        _json => JSON->new->uft8->pretty(1),
    };
    bless $self, $class;
    return $self;
}


sub build_driver {
    my $driver = Selenium::Chrome->new(
                extra_capabilities => {
                    'goog:chromeOptions' => {
                        args => ['headless', 'disable-notifications', 'disable-gpu', 'window-size=1920,1080', 'no-sandbox', 'disable-extensions' ,'start-maximized' ],
                prefs => {
                    'download.default_directory' => '/home/vine/files'
                },
            }
        }
    );
    return $driver;
}

sub return_error{
    my $self = shift;
    my $args = shift;
    my $msg = $args->{msg};
    return $self->{_json}->encode({
        result =>{msg=>$msg}
    });
}

sub return_progress{
    my $self = shift;
    my $args = shift;
    my $msg = $args->{msg};
    return $self->{_json}->encode({
        result =>{msg=>$msg}
    });
}


sub do_screenshot{
    my $self = shift;
    my $args = shift;
    my $cnt = $self->{_png_cnt};
    $driver->capture_screenshot("screenshot".${cnt}++.".png");
    $self->{_png_cnt} = $cnt;
}

sub get_target{
    my $self = shift;
    my $args = shift;
    my $target = $args->{target} || "https://vinelink.vineapps.com/search/CA/Person";
    my $title = $self->{_driver}->get_title;
    unless ($title){
        return $self->do_error({ data=>$target, msg=>"Could not connect to this target " });
    }
    $self->return_progress({ msg => "Connecting to $target "} );
}


sub sign_in{
    my $self = shift;
    my $driver = $self->{_driver};
    if ( $self->element_exists({exp=>'//*[@id="vl-menu-options-sign-in-button"]'})){
        $self->check_pp($driver);
        my $button = $driver->find_element('//*[@id="vl-menu-options-sign-in-button"]');
        $button->click();
    }
    if ( $self->element_exists({exp=>'//*[@id="mat-input-0"]'})){
        $self->check_pp();
        $input = $driver->find_element('//*[@id="mat-input-0"]');
        $input->send_keys($self->{_user});
        $input = $driver->find_element('//*[@id="mat-input-1"]');
        $input->send_keys($self->{_password});
    }
    if ( $self->element_exists({exp=>'//*[@id="vl-login-btn"]'})){
        $driver->execute_script(qq~
            var action = document.querySelector('#vl-login-btn>span');
            action.click();
        ~);
    }
    $self->return_progress({ msg => " Sign in for  ".$self->{_user} } );
}



sub do_search{
    my $self = shift;
    my $driver = $self->{_driver};
    my $element;

    if ( $self->element_exists({exp=>'//*[@id="person-search-type-select"]'}) ){
        $element = $driver->find_element('//*[@id="person-search-type-select"]/div');
        $element->click;
    }
    if ( $self->element_exists({exp=>'//*[@id="person-search-type-select-panel"]'}) ){
        $element = $driver->find_element('//*[@id="person-search-type-select-panel"]/mat-option');
        $element->click;
    }

    if ( $self->element_exists({exp=>'//*[@id="person-last-name-input"]'}) ){
        $element = $driver->find_element('//*[@id="person-last-name-input"]');
        $element->send_keys($self->{_search_value});
    }

    if ( $self->element_exists({exp=>'//*[@id="partial-search-checkbox"]'}) ){
     $driver->execute_script(qq~ 
         var action = document.querySelector('#partial-search-checkbox-input.mat-checkbox-input.cdk-visually-hidden');
         action.click();
        ~);
    }
    $return_value = 0;
    if ( $self->element_exists({exp=>'//*[@id="person-search-form-actions"]'}) ){
        $return_value = $driver->execute_script(qq~ 
            var action = document.querySelector('#person-search-form-actions>button');

            var return_value = 0;
            var b = document.querySelector('#search-button')
            if (b.disabled){
              return 1;
            }
            action.click();
        ~);
    }
    return $return_value if ($return_value);
    $self->return_progress({ msg => "Prepare search ".$self->{_search_value} } );
}

sub extract_pages{
    my $self = shift;
    my $driver = $self->{_driver};
    my $search_value = $self->{_search_value};

    if ( $self->element_exists({exp=>'//*[@id="pnf-main-header"]'}) ){
        my $msg = $driver->execute_script(qq~
            var return_value = " ";
            var mh = document.getElementById('pnf-main-header');
            if (mh){
                if (mh.innerText =='No results found'){
                    return_value =   mh.innerText; 
                }
            }
            if (return_value === " "){
                var s = document.querySelector('body > div.nw-main-body-block > h1');
                if (s){
                    if (s.innerText == 'VINE is not working right now'){
                        return_value = s.innerText;
                    }
                }
            }
            return return_value;
        ~);
        $driver->shutdown_binary;
        $msg .= " for $search_value ";
        return $self->return_error({ msg => $msg  });
    }

    while(1){
        if ( $self->element_exists({exp=>'//*[@id="person-search-search-terms"]'}) ){
            last;
        }
    }

    $file_cnt = $self->{_file_cnt};
    while(1){ 
        $file_cnt++;
        $driver->execute_script(qq~
            var tag = "$file_cnt"; 
            var dfile= '${search_value}_download_'+tag+'.csv';
            var data=[];
            var head=[]; 
            head.push('Name');
            head.push('Facility');
            head.push('ID');
            head.push('Status');
            head.push('Gender');
            data.push(head.join(","));
 
            var person_cards = document.querySelectorAll('html>body>vl-vine-link-app>div>div>main>vl-person-search-results>div>div>vl-person-card');
	
	
            for (var i=0;i<person_cards.length;++i){
                var r=[];
	            var tag = person_cards[i].querySelector('mat-card>mat-card-title>h2');
	            r.push(tag.innerHTML);
	            var tag1 = person_cards[i].querySelector('#person-reporting-agency-name');
	            if (tag1){
	                r.push(tag1.innerText);
                } else {
	                r.push("No agency");
	            }
	            var tag2 = person_cards[i].querySelector('#person-person-context-refid-value');
	            if (tag2){
	                r.push(tag2.innerText);
	            } else {
	                r.push("No id found");
	            }
	            var tag3 = person_cards[i].querySelector('#person-custody-status-value');
	            if (tag3){
	                r.push(tag3.innerText);
	            } else {
	                r.push("No status found")
	            }

                var tag4 = person_cards[i].querySelector('#person-gender-value');
                if (tag4){
                    r.push(tag4.innerText);
                } else {
                    r.push("No Gender Found");
                }
	  
                data.push(r.join(","));
            }
	
	        csv_file = new Blob([data.join("\\n")], {type: "text/csv"});
	
	        download_link = document.createElement("a");

            download_link.download = dfile;

            download_link.href = window.URL.createObjectURL(csv_file);
	
            download_link.style.display = "none";
	
            document.body.appendChild(download_link);
	
            download_link.click();
	
        ~);
        my ($continue) = $self->check_continue();
        unless ($continue){
            last;
        }
    }
}

sub check_continue{
    my $self = shift;
    my $driver = $self->{_driver};
    my $continue = 0;
    if ( $self->element_exists({exp=>'//*[@id="person-search-pagination-button"]'}) ){
       $driver->execute_script(qq~
       var action = document.querySelector('#person-search-pagination-button.mat-focus-indicator.mat-flat-button.mat-button-base.mat-primary');
       action.click();
       ~);
       $continue = 1;
    }
    return ($continue);
}

sub element_exists{
    my $self = shift;
    my $args = shift;
    my $driver = $self->{_driver};
    my $exp = $args->{exp};
    my $values;
    $values = $driver->find_elements($exp);
    my $cnt = scalar @{$values};
    return ($cnt);
}
    

sub check_pp{
    my $self = shift;
    $driver = $self->{_driver};
    my $element;
    if ( $self->element_exists({exp=>'//*[text()[contains(.,"OK")]]'})){
        $element = $driver->find_element('//*[text()[contains(.,"OK")]]');
        $element->click;
    }

    if ( $self->element_exists({exp=>'//*[text()[contains(.,"Got It")]]'})){
        $element = $driver->find_element('//*[text()[contains(.,"Got It")]]');
        $element->click;
        $element->click;
    }
}


sub browser_error{
    my $self = shift;
    my $driver = $self->{_driver};
    if ( $self->element_exists({exp=>'//*[@id="mat-dialog-title-0"]'}) ){
        my $return_error = 0;
        $return_error = $driver->execute_script(qq~
                var error = document.querySelector('#mat-dialog-title-0');
                var error_button;
                var return_error;
                if (error.innerHTML === 'Oops!'){
                    error_button = document.querySelector('#mat-dialog-0 > vl-error-dialog > div > mat-dialog-actions > button');
                    return_error = 1;
                }
                return return_error;

            ~);
    }
    if ($return_error){
        $self->return_error({ msg =>'Vine had an issue - need to restart search ' });
    }
}
        

