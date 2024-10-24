:- use_module(library(http/thread_httpd)).       % For the HTTP server
:- use_module(library(http/http_dispatch)).      % For dispatching handlers
:- use_module(library(http/html_write)).         % For HTML generation
:- use_module(library(http/http_parameters)).    % For handling form parameters
:- use_module(library(http/html_head)).
:- use_module(library(http/http_server_files)).
% Start the server on a specified port
start_server(Port) :-
    http_server(http_dispatch, [port(Port)]).



% Define routes for the web pages
:- http_handler(root(.), cat_page_handler, []).       % Home page for the form
:- http_handler(root(identify), identify_handler, []).% Form submission handling
% :- http_alias(css, 'css').
% :- http_alias(css, css).

:- http_handler(css('styles.css'), http_reply_file('styles.css', []), []).
:- http_handler(css('result.css'), http_reply_file('result.css', []), []).

% http:location(css, root(css), []).
% HTML page to display the form
cat_page_handler(_Request) :-
    reply_html_page(
        title('Cat Family Identification'),
        [ \html_requires(css('styles.css')), % Including an external CSS file (styles.css)
          h1('Cat Family Expert System'),
          div([class='form-container'],
              form([action='/identify', method='POST'],
                   [ div([class='input-group'], 
                         [label([for=color], 'Color: '), 
                          select([name=color], [
                            option([value=''], 'Unknown'),
                              option([value=yellow_black_spots], 'Yellow with Black Spots'),
                              option([value=black], 'Black'),
                              option([value=golden], 'Golden'),
                              option([value=reddish_brown], 'Reddish Brown'),
                              option([value=bay_red], 'Bay Red'),
                              option([value=yellowish_grey], 'Yellowish Grey'),
                              option([value=sandy], 'Sandy'),

                              option([value=grey_brown], 'Grey Brown'),
                              option([value=grayish], 'Grayish'),
                              option([value=grayish_brown], 'Grayish Brown'),
                              option([value=brown], 'Brown'),
                              option([value=spotted], 'Spotted'),
                              option([value=grey_white], 'Grey White'),
                              option([value=grey], 'Grey'),
                              option([value=tawny], 'Tawny'),
                              option([value=grey], 'Grey'),
                              option([value=orange_black_stripes], 'Orange with Black Stripes'),
                              option([value=grayish_brown], 'Grayish Brown'),
                              option([value=varies], 'Varies')  % For domestic cats
                          ])
                         ]),
                     div([class='input-group'], 
                         [label([for=size], 'Size: '), 
                          select([name=size], [
                            option([value=''], 'Unknown'),
                              option([value=small], 'Small'),
                              option([value=medium], 'Medium'),
                              option([value=large], 'Large')
                          ])
                         ]),
                     div([class='input-group'], 
                         [label([for=temperament], 'Temperament: '), 
                          select([name=temperament], [
                            option([value=''], 'Unknown'),
                              option([value=solitary], 'Solitary'),
                              option([value=shy], 'Shy'),
                              option([value=aggressive], 'Aggressive'),
                              option([value=curious], 'Curious'),
                              option([value=social], 'Social'),
                              option([value=varies], 'Varies')  % For domestic cats
                          ])
                         ]),
                     div([class='input-group'], 
                         [label([for=region], 'Region: '), 
                          select([name=region], [
                            option([value=''], 'Unknown'),
                              option([value=africa], 'Africa'),
                              option([value=asia], 'Asia'),
                              option([value=europe], 'Europe'),
                              option([value=americas], 'America'),
                              option([value=south_america], 'South America'),
                              option([value=north_america], 'North America'),
                              option([value=andes], 'Andes'),
                              option([value=sunda_islands], 'Sunda Islands'),
                              ([value=southeast_asia], 'South East Asia'),
                              option([value=india], 'India'),
                              option([value=varies], 'Varies')  % For domestic cats
                          ])
                         ]),
                     div([class='input-group'], 
                         [label([for=coat], 'Coat: '), 
                          select([name=coat], [
                            option([value=''], 'Unknown'),
                              option([value=short], 'Short'),
                              option([value=varies], 'Varies')  % For domestic cats
                          ])
                         ]),
                     div([class='input-group'], 
                         [label([for=tail_size], 'Tail Size: '), 
                          select([name=tail_size], [
                            option([value=''], 'Unknown'),
                              option([value=short], 'Short'),
                              option([value=medium], 'Medium'),
                              option([value=long], 'Long'),
                              option([value=varies], 'Varies')  % For domestic cats
                          ])
                         ]),
                     div([class='input-group'], 
                         [label([for=vocalization], 'Vocalization: '), 
                          select([name=vocalization], [
                            option([value=''], 'Unknown'),
                              option([value=silent], 'Silent'),
                              option([value=low], 'Low'),
                              option([value=loud], 'Loud'),
                              option([value=varies], 'Varies')  % For domestic cats
                          ])
                         ]),
                     div([class='submit-button'],
                         input([type=submit, value='Identify']))
                   ])
              )
         ] ).



identify_handler(Request) :-
    % Extracting form parameters
    http_parameters(Request,
                    [ color(Color, [optional(true)]),
                      size(Size, [optional(true)]),
                      temperament(Temperament, [optional(true)]),
                      region(Region, [optional(true)]),
                      coat(Coat, [optional(true)]),
                      tail_size(TailSize, [optional(true)]),
                      vocalization(Vocalization, [optional(true)])
                    ]),
    % Gather all matching cat species using findall/3
    findall(Species, identify_cat_web(Species, Color, Size, Temperament, Region, Coat, TailSize, Vocalization, _), SpeciesList),
    % Sort and remove duplicates
    sort(SpeciesList, UniqueSpeciesList),
    % Check if there are no matching species
    ( UniqueSpeciesList = []
    -> Results = ['No species found']
    ;  Results = UniqueSpeciesList
    ),
    reply_html_page(
        title('Cat Identification Result'),
        [  \html_requires(css('result.css')),
           h1('Identification Result'),
           p(['The identified cat species are:']),
           ul([class='species-list'], \list_species(Results))
        ]
    ).



    
% Helper to display the list of species in HTML
list_species([]) --> 
    html(li(['No more species found'])).
list_species([Species|Rest]) -->
    { image_url(Species, ImageURL) },
    html(li([p([Species]), img([src(ImageURL), alt(Species), class='cat-image'])])),
    list_species(Rest).



    cat(cheetah).
    cat(african_golden_cat).
    cat(caracal).
    cat(bornean_bay_cat).
    cat(asiatic_golden_cat).
    cat(jungle_cat).
    cat(sand_cat).
    cat(black_footed_cat).
    cat(european_wildcat).
    cat(afro_asiatic_wildcat).
    cat(chinese_mountain_cat).
    cat(black_panther).

    cat(jaguarundi).
    cat(geoffroys_cat).
    cat(kodkod).
    cat(andean_cat).
    cat(ocelot).
    cat(northern_tiger_cat).
    cat(southern_tiger_cat).
    cat(eastern_tiger_cat).
    cat(central_chilean_pampas_cat).
    cat(brazilian_pampas_cat).
    cat(uruguayan_pampas_cat).
    cat(northern_pampas_cat).
    cat(southern_pampas_cat).
    cat(margay).
    cat(serval).
    cat(eurasian_lynx).
    cat(iberian_lynx).
    cat(canada_lynx).
    cat(bobcat).
    cat(mainland_clouded_leopard).
    cat(sunda_clouded_leopard).
    cat(pallas_cat).
    cat(lion).
    cat(jaguar).
    cat(leopard).
    cat(tiger).
    cat(snow_leopard).
    cat(marbled_cat).
    cat(mainland_leopard_cat).
    cat(sunda_leopard_cat).
    cat(flat_headed_cat).
    cat(rusty_spotted_cat).
    cat(fishing_cat).
    cat(puma).
    cat(african_wildcat).
    cat(domestic_cat).
    
    image_url(cheetah, "https://transforms.stlzoo.org/production/animals/cheetah-01-01.jpg?w=1200&h=1200&auto=compress%2Cformat&fit=crop&dm=1658942789&s=16e742d7a9628bb93b63a7922179b43e").
    image_url(african_golden_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSD-lvv-_yDQG2cyGnzEK3Hm8rKQwbsJdbJb6BbFunQL8nQMTQPjCB_mhKSAM0wL5jUNb34ugZp_znUSybMk6QD6FdHCiEr7DKcPY0BAA").
    image_url(caracal, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRjgMN25RFdU-PEXdNTgKBccTYxbK0rB0X4TyorgIGka2b7xGv0lFWMSU88nqiFbOAQsEyM8yI_wCf49B3Flo7kV7_Btw0FOfvd55tisT4").
    image_url(bornean_bay_cat, "https://imgs.mongabay.com/wp-content/uploads/sites/20/2024/04/15134501/9a-Kuching-007-Borneos-bay-cat-768x512.jpg").
    image_url(asiatic_golden_cat, "https://unitedliberalfoundation.com/wp-content/uploads/2023/01/Asian_golden_cat1.jpg").
    image_url(jungle_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxiFBCpPNRfqc2HUU1qjBJIVLlFbWmTH5L5A&s").
    image_url(sand_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSf8bVPK9Xb7owNSKT_Oe4zV--I3GBQHtmosA&s").
    image_url(black_footed_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1QyIhlQ2ZN2TlfHoldhClrtWs4Xgxbjg0bw&s").
    image_url(european_wildcat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ9MStBUaxWdNeZW7tFT5Uuy8-6P5L4q-BMWg&s").
    image_url(afro_asiatic_wildcat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_tq4f-_q82uKwaz8KcxR6HZgQcwofJ_RiDg&s").
    image_url(chinese_mountain_cat, "https://upload.wikimedia.org/wikipedia/commons/4/41/Chinese_Mountain_Cat_%28Felis_Bieti%29_in_XiNing_Wild_Zoo_2.jpg").
    image_url(jaguarundi, "https://inaturalist-open-data.s3.amazonaws.com/photos/554113/large.jpg").
    image_url(geoffroys_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR9Y0YBsxkdBQG7EKYaXnOMvOk8oPEkP2Zitg&s").
    image_url(kodkod, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZ0wRwxKNz2R6BTuaQlXZaMK5_zzdfYPh6wg&s").
    image_url(andean_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCPWTC1vtaBtiq1i1lVEdNRUasEyNMsSIPfQ&s").
    image_url(ocelot, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSO9Zo0g-rsts6gLAjrhCmkDIrKAtg0DVjTUw&s").
    image_url(northern_tiger_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTrnL4RBkWGyicwZ2J11Z9_qefeanSQO6xC7w&s").
    image_url(southern_tiger_cat, "https://wildcatconservation.org/wp-content/uploads/2018/06/L-guttulus.jpg").
    image_url(eastern_tiger_cat, "https://upload.wikimedia.org/wikipedia/commons/thumb/3/32/Leopardus_tigrinus_-_Parc_des_F%C3%A9lins.jpg/800px-Leopardus_tigrinus_-_Parc_des_F%C3%A9lins.jpg").
    image_url(central_chilean_pampas_cat, "https://www.joelsartore.com/wp-content/uploads/stock/ANI100/ANI100-00115.jpg").
    image_url(brazilian_pampas_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7XG06nNAOWsLymjs-zxj_Ezai1hmHRpIRww&s").
    image_url(uruguayan_pampas_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIjABIj2X28opIlXhhyY8AGTOUOUfTVudVzw&s").
    image_url(northern_pampas_cat, "https://i.pinimg.com/736x/32/6c/2c/326c2c2b147238ea764461b69de4b986.jpg").
    image_url(southern_pampas_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTVAfDC0V72pmuRn-rKjVUXC7FIPUxRpdvT_g&s").
image_url(margay, "https://cdn.britannica.com/92/10092-004-89EDB960/Margay.jpg").
image_url(serval, "https://i.natgeofe.com/k/8a14407c-747f-4750-a9ec-aaa81cfe88a9/serval-full-body.jpg").
image_url(eurasian_lynx, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRFfK_n6zIonDbcFZM8wGU5FHMQRUeygk5Gng&s").
image_url(iberian_lynx, "https://i.guim.co.uk/img/media/9cb888807f72607389a86eeff5fca5ec9e35e6d1/0_184_5472_3283/master/5472.jpg?width=1200&height=900&quality=85&auto=format&fit=crop&s=95b0e81bdfc5f3d8e680da13510e739a").
image_url(canada_lynx, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS05-F-hvD5RDo9VWdfHRMl5YK-UpZsHblICg&s").
image_url(bobcat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT8zFxdnTxJHNHNRSFr27NHdL8aycfeSpfqDg&s").
image_url(mainland_clouded_leopard, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSFS7dMrN6MIw_f12z9RrUuwsmY246xTWoiTQ&s").
image_url(sunda_clouded_leopard, "https://wildcatconservation.org/wp-content/uploads/2012/12/Clouded-leopard-Hearn-Ross.75.jpg").
image_url(pallas_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcScvMCy6ySTAKnYLnIeYgpFz6z97dmjEHnRrw&s").
image_url(lion, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ5mY_cvo6-XP-Fivsf9qUh_gIIDBZunOhq2Q&s").
image_url(jaguar, "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Standing_jaguar.jpg/640px-Standing_jaguar.jpg").
image_url(leopard, "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Nagarhole_Kabini_Karnataka_India%2C_Leopard_September_2013.jpg/800px-Nagarhole_Kabini_Karnataka_India%2C_Leopard_September_2013.jpg").
image_url(tiger, "https://media.istockphoto.com/id/1420676204/photo/portrait-of-a-royal-bengal-tiger-alert-and-staring-at-the-camera-national-animal-of-bangladesh.jpg?s=612x612&w=0&k=20&c=0OCYv99Ktv3fJ-YYlg7SetHBJj3pIk58WY7GDy5VCtI=").
image_url(snow_leopard, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGbVI8PzIVtslru2mETM5lb7xMv-sEqecq3Q&s").
image_url(marbled_cat, "https://www.tbsnews.net/sites/default/files/styles/infograph/public/images/2023/09/07/marbled_cats_are_the_old-world_equivalent_of_the_south_american_margay.jpg").
image_url(mainland_leopard_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSJfGKXXjgULTTFmexut0kgIJVWnve0IhM6yw&s").
image_url(sunda_leopard_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT7CHCp7CAcM-KxZXd9iKI2rZEJ3lKxEzPU3Q&s").
image_url(flat_headed_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSO1Rkt2HbgGkJmrjvIQe3CYPvf45iD7Cyvsw&s").
image_url(rusty_spotted_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcROU5xCRRAmLf3-yGt3QbXCNmW5lDCUqwsTEQ&s").
image_url(fishing_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZXh5HT6va4aEYmeS6qzXuYXs8ZHORCJr4lQ&s").
image_url(puma, "https://static.scientificamerican.com/sciam/cache/file/D6118F41-EA35-4541-954B0B89D0FCA186_source.jpg?crop=16%3A9%2Csmart&w=1920").
image_url(domestic_cat, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQK5CqiQQDLVEVd_mEtfKpqF8MTZj0SqiEEWg&s").
image_url(black_panther, "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSUOFip0mZ6BSUFqNlzBfSG2NFYpY6Kh44AZA&s").
    
    
    color(cheetah, yellow_black_spots).
    color(african_golden_cat, golden).
    color(caracal, reddish_brown).
    color(bornean_bay_cat, bay_red).
    color(asiatic_golden_cat, golden).
    color(jungle_cat, yellowish_grey).
    color(sand_cat, sandy).
    color(black_footed_cat, black ).
    color(european_wildcat, grey_brown).
    color(afro_asiatic_wildcat, grayish).
    color(chinese_mountain_cat, grayish_brown).
    color(jaguarundi, brown).
    color(geoffroys_cat, spotted).
    color(kodkod, spotted).
    color(andean_cat, grey_white).
    color(ocelot, spotted).
    color(northern_tiger_cat, spotted).
    color(southern_tiger_cat, spotted).
    color(eastern_tiger_cat, spotted).
    color(central_chilean_pampas_cat, grey).
    color(brazilian_pampas_cat, grey).
    color(uruguayan_pampas_cat, grey).
    color(northern_pampas_cat, grey).
    color(southern_pampas_cat, grey).
    color(margay, spotted).
    color(serval, spotted).
    color(eurasian_lynx, reddish_brown).
    color(iberian_lynx, reddish_brown).
     color(iberian_lynx, spotted).
    color(canada_lynx, grey_brown).
    color(bobcat, brown).
    color(mainland_clouded_leopard, brown).
    color(sunda_clouded_leopard, brown).
    color(pallas_cat, grayish).
    color(lion, brown).
    color(jaguar, yellow_black_spots).
    color(leopard, yellow_black_spots).
    color(tiger, orange_black_stripes).
    color(snow_leopard, grayish).
    color(marbled_cat, spotted).
    color(mainland_leopard_cat, brown).
    color(sunda_leopard_cat, brown).
    color(flat_headed_cat, grayish).
    color(rusty_spotted_cat, brown).
    color(fishing_cat, gray).
    color(puma, tawny).
    color(african_wildcat, tawny).
    color(domestic_cat, varies).
    color(black_panther, black).
    
    
    size(cheetah, large).
    size(african_golden_cat, medium).
    size(caracal, medium).
    size(bornean_bay_cat, medium).
    size(asiatic_golden_cat, medium).
    size(jungle_cat, medium).
    size(sand_cat, small).
    size(black_footed_cat, small).
    size(european_wildcat, medium).
    size(afro_asiatic_wildcat, medium).
    size(chinese_mountain_cat, medium).
    size(jaguarundi, medium).
    size(geoffroys_cat, small).
    size(kodkod, small).
    size(andean_cat, small).
    size(ocelot, medium).
    size(northern_tiger_cat, small).
    size(southern_tiger_cat, small).
    size(eastern_tiger_cat, small).
    size(central_chilean_pampas_cat, small).
    size(brazilian_pampas_cat, small).
    size(uruguayan_pampas_cat, small).
    size(northern_pampas_cat, small).
    size(southern_pampas_cat, small).
    size(margay, medium).
    size(serval, medium).
    size(eurasian_lynx, large).
    size(iberian_lynx, large).
    size(canada_lynx, large).
    size(bobcat, medium).
    size(mainland_clouded_leopard, medium).
    size(sunda_clouded_leopard, medium).
    size(pallas_cat, small).
    size(lion, large).
    size(jaguar, large).
    size(leopard, large).
    size(tiger, large).
    size(snow_leopard, medium).
    size(marbled_cat, medium).
    size(mainland_leopard_cat, medium).
    size(sunda_leopard_cat, medium).
    size(flat_headed_cat, small).
    size(rusty_spotted_cat, small).
    size(fishing_cat, medium).
    size(puma, large).
    size(african_wildcat, medium).
    size(domestic_cat, small).
    size(black_panther,large).
    
    
    
    temperament(cheetah, solitary).
    temperament(african_golden_cat, shy).
    temperament(caracal, solitary).
    temperament(bornean_bay_cat, shy).
    temperament(asiatic_golden_cat, solitary).
    temperament(jungle_cat, aggressive).
    temperament(sand_cat, solitary).
    temperament(black_footed_cat, solitary).
    temperament(european_wildcat, solitary).
    temperament(afro_asiatic_wildcat, solitary).
    temperament(chinese_mountain_cat, solitary).
    temperament(jaguarundi, solitary).
    temperament(geoffroys_cat, aggressive).
    temperament(kodkod, curious).
    temperament(andean_cat, shy).
    temperament(ocelot, aggressive).
    temperament(northern_tiger_cat, aggressive).
    temperament(southern_tiger_cat, aggressive).
    temperament(eastern_tiger_cat, aggressive).
    temperament(central_chilean_pampas_cat, solitary).
    temperament(brazilian_pampas_cat, solitary).
    temperament(uruguayan_pampas_cat, solitary).
    temperament(northern_pampas_cat, solitary).
    temperament(southern_pampas_cat, solitary).
    temperament(margay, aggressive).
    temperament(serval, aggressive).
    temperament(eurasian_lynx, solitary).
    temperament(iberian_lynx, aggressive).
    temperament(canada_lynx, solitary).
    temperament(bobcat, solitary).
    temperament(mainland_clouded_leopard, solitary).
    temperament(sunda_clouded_leopard, solitary).
    temperament(pallas_cat, shy).
    temperament(lion, social).
    temperament(jaguar, solitary).
    temperament(leopard, solitary).
    temperament(tiger, aggressive).
    temperament(snow_leopard, solitary).
    temperament(marbled_cat, shy).
    temperament(mainland_leopard_cat, solitary).
    temperament(sunda_leopard_cat, solitary).
    temperament(flat_headed_cat, shy).
    temperament(rusty_spotted_cat, shy).
    temperament(fishing_cat, aggressive).
    temperament(puma, solitary).
    temperament(african_wildcat, solitary).
    temperament(domestic_cat, varies).
    temperament(black_panther, solitary).
    
    
    
    region(cheetah, africa).
    region(african_golden_cat, africa).
    region(caracal, africa).
    region(bornean_bay_cat, asia).
    region(asiatic_golden_cat, asia).
    region(jungle_cat, asia).
    region(sand_cat, desert).
    region(black_footed_cat, africa).
    region(european_wildcat, europe).
    region(afro_asiatic_wildcat, africa).
    region(chinese_mountain_cat, asia).
    region(jaguarundi, america).
    region(geoffroys_cat, south_america).
    region(kodkod, south_america).
    region(andean_cat, andes).
    region(ocelot, america).
    region(northern_tiger_cat, south_america).
    region(southern_tiger_cat, south_america).
    region(eastern_tiger_cat, south_america).
    region(central_chilean_pampas_cat, south_america).
    region(brazilian_pampas_cat, south_america).
    region(uruguayan_pampas_cat, south_america).
    region(northern_pampas_cat, south_america).
    region(southern_pampas_cat, south_america).
    region(margay, america).
    region(serval, africa).
    region(eurasian_lynx, europe).
    region(iberian_lynx, europe).
    region(canada_lynx, north_america).
    region(bobcat, north_america).
    region(mainland_clouded_leopard, asian_tropics).
    region(sunda_clouded_leopard, sunda_islands).
    region(pallas_cat, asia).
    region(lion, africa).
    region(lion, india).
    region(jaguar, america).
    region(jaguar, asia).
    region(leopard, africa).
      region(leopard, asia).
      region(lion, asia).
      region(tiger, india).
      region(leopard, india).
      region(tiger,europe).
  
    region(tiger, asia).
    region(snow_leopard, asia).
    region(snow_leopard, europe).
    region(marbled_cat, asia).
    region(mainland_leopard_cat, asia).
    region(sunda_leopard_cat, sunda_islands).
    region(flat_headed_cat, southeast_asia).
    region(rusty_spotted_cat, india).
    region(fishing_cat, southeast_asia).
    region(puma, america).
    region(african_wildcat, africa).
    region(domestic_cat, america).
    region(domestic_cat, asia).
    region(domestic_cat, africa).
    region(domestic_cat, europe).
    region(domestic_cat, south_america).
    region(domestic_cat, southeast_asia).
        region(domestic_cat, india).
        region(black_panther,africa).
        region(black_panther, india).
        region(black_panther, asia).
        region(black_panther, south_america).

    
    
    coat(cheetah, short).
    coat(african_golden_cat, short).
    coat(caracal, short).
    coat(bornean_bay_cat, short).
    coat(asiatic_golden_cat, short).
    coat(jungle_cat, short).
    coat(sand_cat, short).
    coat(black_footed_cat, short).
    coat(european_wildcat, short).
    coat(afro_asiatic_wildcat, short).
    coat(chinese_mountain_cat, short).
    coat(jaguarundi, short).
    coat(geoffroys_cat, short).
    coat(kodkod, short).
    coat(andean_cat, short).
    coat(ocelot, short).
    coat(northern_tiger_cat, short).
    coat(southern_tiger_cat, short).
    coat(eastern_tiger_cat, short).
    coat(central_chilean_pampas_cat, short).
    coat(brazilian_pampas_cat, short).
    coat(uruguayan_pampas_cat, short).
    coat(northern_pampas_cat, short).
    coat(southern_pampas_cat, short).
    coat(margay, short).
    coat(serval, short).
    coat(eurasian_lynx, short).
    coat(iberian_lynx, short).
    coat(canada_lynx, short).
    coat(bobcat, short).
    coat(mainland_clouded_leopard, short).
    coat(sunda_clouded_leopard, short).
    coat(pallas_cat, short).
    coat(lion, short).
    coat(jaguar, short).
    coat(leopard, short).
    coat(tiger, short).
    coat(snow_leopard, short).
    coat(marbled_cat, short).
    coat(mainland_leopard_cat, short).
    coat(sunda_leopard_cat, short).
    coat(flat_headed_cat, short).
    coat(rusty_spotted_cat, short).
    coat(fishing_cat, short).
    coat(puma, short).
    coat(african_wildcat, short).
    coat(domestic_cat, varies).
    coat(black_panther, short).
    
    
    tail_size(cheetah, long).
    tail_size(african_golden_cat, medium).
    tail_size(caracal, short).
    tail_size(bornean_bay_cat, medium).
    tail_size(asiatic_golden_cat, medium).
    tail_size(jungle_cat, medium).
    tail_size(sand_cat, short).
    tail_size(black_footed_cat, short).
    tail_size(european_wildcat, medium).
    tail_size(afro_asiatic_wildcat, medium).
    tail_size(chinese_mountain_cat, medium).
    tail_size(jaguarundi, medium).
    tail_size(geoffroys_cat, medium).
    tail_size(kodkod, short).
    tail_size(andean_cat, long).
    tail_size(ocelot, long).
    tail_size(northern_tiger_cat, long).
    tail_size(southern_tiger_cat, long).
    tail_size(eastern_tiger_cat, long).
    tail_size(central_chilean_pampas_cat, short).
    tail_size(brazilian_pampas_cat, short).
    tail_size(uruguayan_pampas_cat, short).
    tail_size(northern_pampas_cat, short).
    tail_size(southern_pampas_cat, short).
    tail_size(margay, short).
    tail_size(serval, long).
    tail_size(eurasian_lynx, long).
    tail_size(iberian_lynx, long).
    tail_size(canada_lynx, long).
    tail_size(bobcat, short).
    tail_size(mainland_clouded_leopard, long).
    tail_size(sunda_clouded_leopard, long).
    tail_size(pallas_cat, short).
    tail_size(lion, long).
    tail_size(jaguar, long).
    tail_size(leopard, long).
    tail_size(tiger, long).
    tail_size(snow_leopard, short).
    tail_size(marbled_cat, long).
    tail_size(mainland_leopard_cat, long).
    tail_size(sunda_leopard_cat, long).
    tail_size(flat_headed_cat, short).
    tail_size(rusty_spotted_cat, short).
    tail_size(fishing_cat, short).
    tail_size(puma, long).
    tail_size(african_wildcat, medium).
    tail_size(domestic_cat, varies).
    tail_size(black_panther,long).
    
    vocalization(cheetah, silent).
    vocalization(african_golden_cat, silent).
    vocalization(caracal, low).
    vocalization(bornean_bay_cat, silent).
    vocalization(asiatic_golden_cat, low).
    vocalization(jungle_cat, loud).
    vocalization(sand_cat, low).
    vocalization(black_footed_cat, low).
    vocalization(european_wildcat, silent).
    vocalization(afro_asiatic_wildcat, silent).
    vocalization(chinese_mountain_cat, silent).
    vocalization(jaguarundi, low).
    vocalization(geoffroys_cat, silent).
    vocalization(kodkod, silent).
    vocalization(andean_cat, silent).
    vocalization(ocelot, low).
    vocalization(northern_tiger_cat, silent).
    vocalization(southern_tiger_cat, silent).
    vocalization(eastern_tiger_cat, silent).
    vocalization(central_chilean_pampas_cat, silent).
    vocalization(brazilian_pampas_cat, silent).
    vocalization(uruguayan_pampas_cat, silent).
    vocalization(northern_pampas_cat, silent).
    vocalization(southern_pampas_cat, silent).
    vocalization(margay, low).
    vocalization(serval, loud).
    vocalization(eurasian_lynx, loud).
    vocalization(iberian_lynx, loud).
    vocalization(canada_lynx, loud).
    vocalization(bobcat, loud).
    vocalization(mainland_clouded_leopard, loud).
    vocalization(sunda_clouded_leopard, loud).
    vocalization(pallas_cat, silent).
    vocalization(lion, loud).
    vocalization(jaguar, loud).
    vocalization(leopard, loud).
    vocalization(tiger, loud).
    vocalization(snow_leopard, loud).
    vocalization(marbled_cat, silent).
    vocalization(mainland_leopard_cat, silent).
    vocalization(sunda_leopard_cat, silent).
    vocalization(flat_headed_cat, silent).
    vocalization(rusty_spotted_cat, silent).
    vocalization(fishing_cat, loud).
    vocalization(puma, loud).
    vocalization(african_wildcat, silent).
    vocalization(domestic_cat, varies).
    vocalization(black_panther,silent).
    
    matches(Expected, Actual) :- var(Expected) ; Expected = Actual.
    
    % Rule to identify a cat with flexible input parameters
    identify_cat_web(Species, Color, Size, Temperament, Region, Coat, TailSize, Vocalization,ImageURL) :-
        color(Species, ActualColor),
        size(Species, ActualSize),
        temperament(Species, ActualTemperament),
        region(Species, ActualRegion),
        coat(Species, ActualCoat),
        tail_size(Species, ActualTailSize),
        vocalization(Species, ActualVocalization),
        image_url(Species,ImageURL),
        matches(Color, ActualColor),
        matches(Size, ActualSize),
        matches(Temperament, ActualTemperament),
        matches(Region, ActualRegion),
        matches(Coat, ActualCoat),
        matches(TailSize, ActualTailSize),
        matches(Vocalization, ActualVocalization).
    
    
    
% Starting the server at port 8080
:- initialization(start_server(8080)).