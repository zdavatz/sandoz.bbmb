# Manual tests

## Setup

Modify etc/config.yml to
* mail_order_to:      # must be a local user
* mail_confirm_cc:    # must be a local user
* inject_error_to:    # must be a local user
* confirm_error_to:   # must be a local user
* bbmb_dir:           # directory of the test application
* polling_file:       # directory of the test application
* ydim_config:        # directory of the test application

* Adapt the /etc/apache/vhosts.d/sandoz.bbmb.ch.conf
* Adapt the /service/sandoz.bbmb.ch/run

## Testing the importer

* Copy Artikel.txt and Kunden.txt to the directory specified in etc/polling.yml (chroot-jail/home/sandoz/data)
* Set run_only_once_at_startup to true in lib/bbmb/util/server.rb
* start the app using `sudo -u bbmb bundle exec rackup`
* Verify that you see lines like th following in the SBSM log file (log/<year>/<month>/<day>/app_log

  D, [2017-05-29T15:26:39.415008 #26960] DEBUG -- : server.rb:94:in `block (2 levels) in run_updater' update starting
  I, [2017-05-29T15:26:39.415137 #26960]  INFO -- : started bbmb-server on druby://localhost:12004
  I, [2017-05-29T15:26:48.235572 #26960]  INFO -- : updater.rb:12:in `run' Updated.run started at 2017-05-29 15:26:48 +0200
  I, [2017-05-29T15:26:48.239039 #26960]  INFO -- : updater.rb:22:in `import' Updater.import using klass BBMB::Util::ProductImporter
  I, [2017-05-29T15:28:50.492505 #26960]  INFO -- : updater.rb:24:in `import' updater String imported 1059 entities
  D, [2017-05-29T15:28:52.299391 #26960] DEBUG -- : server.rb:97:in `block (2 levels) in run_updater' update finished



## Tests as admin user

* login as admin user
** All customers should appear
*** You must be able to sort each column by clicking on the column header. Clicking a second time must invert the search order
*** For customer, e.g.bachmatte
**** you can find them searching via client id, name, plz, ort, email
**** you can select then
**** when clicking on "Umsatz" you see a list of article with prices and total
**** when clicking on numerical value of Umsatz you see a list of orders.
**** Click on an order and you must see the items orders with name, list price, effective price, total, MWSt
** Changing the language to french and back should work
** Select a TEST user and
*** Change a street address (and other fields should work). Values should persist after restarting the app
*** Change the password
*** Generate a new password
*** Change the e-mail
**** When the email is not empty, it should not to possible to save an empty password
**** When setting it to the e-mail of another customer, this change must be refused
** Clicking on Umsatz should display a list of orders (total should match)


## Tests as normal user
* login as a normal user, eg. id 99 TEST
  The home Warenkorb should appear with a least of product
** visiting the following links should work
*** Warenkorb (Home)
*** Archiv
*** Schnellbestellung
**** Adding an item via Suchen must work
**** Deleting an itme must work
*** Katalog
**** Test whether you can add an item to a Bestellung
*** Abschlüsse
*** Promotionen
**** Test whether you can add a HPM item to the Schnellbestellung
*** Kalkulieren
**** Test whether changing the factor works
*** Submit an order
**** Check that it landed in directory specified via the order_destinations in etc/config.yml, eg. via
     order_destinations:
*** Passwort ändern
*** Abmelden
After selecting abmelden the link "Abmelden" should no longer appear.

## Testing the bin/sandoz_admin interface

* Start it via sudo -u bbmb /usr/local/bin/bundle-240 exec bin/sandoz_admin
** Here is a replay of session
  sudo -u bbmb bundle exec bin/virbac_admin
  Verify it with the following commands
  ch.bbmb.sandoz> ODBA.cache.extent(BBMB::Model::Order).size
  -> 45771
  ch.bbmb.sandoz> ODBA.cache.extent(BBMB::Model::Customer).size
  -> 1679
  ch.bbmb.sandoz> ODBA.cache.extent(BBMB::Model::Customer).first
  -> #<BBMB::Model::Customer:0x00000004c0f4f0>
  ch.bbmb.sandoz> ODBA.cache.extent(BBMB::Model::Customer).first.customer_id
  -> test
  ch.bbmb.sandoz> ODBA.cache.extent(BBMB::Model::Customer).last.customer_id
  -> 99
  ch.bbmb.sandoz> ODBA.cache.extent(BBMB::Model::Customer).last.orders.size
  -> 111
  ch.bbmb.sandoz> ODBA.cache.extent(BBMB::Model::Customer).last.orders.first
  -> #<BBMB::Model::Order:0x0000000544be20>
  ch.bbmb.sandoz> ODBA.cache.extent(BBMB::Model::Customer).last.orders.last
  -> #<BBMB::Model::Order:0x000000022902c8>
  ch.bbmb.sandoz> ODBA.cache.extent(BBMB::Model::Customer).last.orders.last.total
  -> 60.88
  ch.bbmb.sandoz> exit
  -> Goodbye
