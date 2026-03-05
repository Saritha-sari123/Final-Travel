CLASS lhc_bksuppl DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setbookingsupplid FOR DETERMINE ON SAVE
      IMPORTING keys FOR bksuppl~setbookingsupplid.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR bksuppl~calculatetotalprice.

ENDCLASS.

CLASS lhc_bksuppl IMPLEMENTATION.

  METHOD setbookingsupplid.

    DATA: max_bookingsuppid   TYPE /dmo/booking_supplement_id,
          bookingsuppliement  TYPE STRUCTURE FOR READ RESULT zsa_Bk_supp_fin_I,
          bookingsuppl_update TYPE TABLE FOR UPDATE zsa_travel_fin_I\\bksuppl.

    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY bksuppl BY \_booking
    FIELDS ( BookingUuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(bookings).


    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY booking BY \_bksuppl
    FIELDS ( BookingSupplementId )
    WITH CORRESPONDING #( bookings )
    LINK DATA(bookingsuppl_links)
    RESULT DATA(bookingsuppliements).


    LOOP AT bookings INTO DATA(booking).

      max_bookingsuppid = '00'.

      LOOP AT bookingsuppl_links INTO DATA(bookingsuppl_link) USING KEY id WHERE source-%tky = booking-%tky.

        bookingsuppliement = bookingsuppliements[ KEY id
                          %tky = bookingsuppl_link-target-%tky ].

        IF bookingsuppliement-BookingSupplementId > max_bookingsuppid.
          max_bookingsuppid = bookingsuppliement-BookingSupplementId.

        ENDIF.
      ENDLOOP.
*
      LOOP AT bookingsuppl_links INTO bookingsuppl_link USING KEY id WHERE source-%tky = booking-%tky.

        bookingsuppliement = bookingsuppliements[ KEY id
                          %tky = bookingsuppl_link-target-%tky ].

        IF bookingsuppliement-BookingSupplementId IS INITIAL.
          max_bookingsuppid += 1.
          APPEND VALUE #( %tky = bookingsuppliement-%tky
                           BookingSupplementId  = max_bookingsuppid
                            ) TO bookingsuppl_update.


        ENDIF.

      ENDLOOP.
    ENDLOOP.
    " use modify EML to update the booking entity with the new booking id number which is max_bookingid

    MODIFY ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY bksuppl
    UPDATE FIELDS ( BookingSupplementId )
    WITH bookingsuppl_update.


  ENDMETHOD.

  METHOD calculateTotalPrice.

    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
  ENTITY bksuppl BY \_booking
  FIELDS ( TravelUuid )
  WITH CORRESPONDING #( keys )
  RESULT DATA(travels).


    MODIFY ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
      ENTITY travel
      EXECUTE reCalcTotalprice
      FROM CORRESPONDING #( travels ).
  ENDMETHOD.

ENDCLASS.

CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setbookingdate FOR DETERMINE ON SAVE
      IMPORTING keys FOR booking~setbookingdate.

    METHODS setbookingid FOR DETERMINE ON SAVE
      IMPORTING keys FOR booking~setbookingid.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR booking~calculatetotalprice.

ENDCLASS.


CLASS lhc_booking IMPLEMENTATION.

  METHOD setbookingdate.
    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY booking
    FIELDS ( BookingDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(dates).

    MODIFY ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY booking
    UPDATE FIELDS ( BookingDate )
    WITH VALUE #( FOR date IN dates (
                 %tky = date-%tky
                 BookingDate = sy-datum
                  ) ).


  ENDMETHOD.

  METHOD setbookingid.



    DATA : max_bookingid   TYPE /dmo/booking_id,
           booking         TYPE STRUCTURE FOR READ RESULT zsa_booking_fin_i,
           bookings_update TYPE TABLE FOR UPDATE zsa_travel_fin_I\\booking.

    "we are reading the booking entities to get the travel UUid for the current booking instance and
    "store in the travels table
    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY booking BY \_travel
    FIELDS ( TravelUuid )
    WITH CORRESPONDING #( keys  )
    RESULT DATA(travels).



    " now reading all the booking related to travel which we got from above travel table

    READ ENTITIES OF  zsa_travel_fin_I IN LOCAL MODE
    ENTITY travel BY \_booking
    FIELDS ( BookingId )
    WITH CORRESPONDING #( travels )
    LINK DATA(booking_links)
    RESULT DATA(bookings).

* deLETE bookings wHERE BookingId is not inITIAL.

    LOOP AT travels INTO DATA(travel).

      max_bookingid = '0000'.

      LOOP AT booking_links INTO DATA(booking_link) USING KEY id WHERE source-%tky = travel-%tky.

        booking = bookings[ KEY id
                          %tky = booking_link-target-%tky ].

        IF booking-BookingId > max_bookingid.
          max_bookingid = booking-BookingId.

        ENDIF.
      ENDLOOP.
*
      LOOP AT booking_links INTO booking_link USING KEY id WHERE source-%tky = travel-%tky.

        booking = bookings[ KEY id
                          %tky = booking_link-target-%tky ].

        IF booking-BookingId IS INITIAL.
          max_bookingid += 1.
          APPEND VALUE #( %tky = booking-%tky
                            bookingid = max_bookingid
                            ) TO bookings_update.


        ENDIF.

      ENDLOOP.
    ENDLOOP.
    " use modify EML to update the booking entity with the new booking id number which is max_bookingid

    MODIFY ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY booking
    UPDATE FIELDS ( BookingId )
    WITH bookings_update.




  ENDMETHOD.

  METHOD calculateTotalPrice.

    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY booking BY \_travel
    FIELDS ( TravelUuid )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).


    MODIFY ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
      ENTITY travel
      EXECUTE reCalcTotalprice
      FROM CORRESPONDING #( travels ).

  ENDMETHOD.

ENDCLASS.
CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR travel RESULT result.
    METHODS settravelid FOR DETERMINE ON SAVE
      IMPORTING keys FOR travel~settravelid.
    METHODS setoverallstatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~setoverallstatus.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~accepttravel RESULT result.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~rejecttravel RESULT result.
    METHODS deductdiscount FOR MODIFY
      IMPORTING keys FOR ACTION travel~deductdiscount RESULT result.
    METHODS getdefaultsfordeductdiscount FOR READ
      IMPORTING keys FOR FUNCTION travel~getdefaultsfordeductdiscount RESULT result.
    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION travel~recalctotalprice.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~calculatetotalprice.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatecustomer.
    METHODS validateagencyid FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateagencyid.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validatedates.

ENDCLASS.


CLASS lhc_travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD settravelid.


    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
      ENTITY travel
      FIELDS ( TravelId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).

    DELETE lt_travel WHERE TravelId IS NOT INITIAL.

    SELECT SINGLE FROM zsa_travel_fin FIELDS MAX( travel_id ) INTO @DATA(lv_travelid_max).

    MODIFY ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( TravelId )
    WITH VALUE #( FOR ls_travel_id IN lt_travel INDEX INTO lv_index
                       ( %tky = ls_travel_id-%tky
                        TravelId = lv_travelid_max + lv_index ) ).



  ENDMETHOD.

  METHOD setoverallstatus.

    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY travel
    FIELDS ( OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_status).

    DELETE lt_status WHERE OverallStatus IS NOT INITIAL.

    MODIFY ENTITIES OF  zsa_travel_fin_i IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR ls_status IN lt_status
     ( %tky = ls_status-%tky
     OverallStatus = 'O'  ) ).



  ENDMETHOD.

  METHOD acceptTravel.
    MODIFY ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                    OverallStatus = 'A'
     ) ).




    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY travel
    ALL FIELDS WITH  CORRESPONDING #( keys )
    RESULT DATA(travels).

    result = VALUE #( FOR travel  IN travels ( %tky = travel-%tky
                                                %param = travel ) ).
  ENDMETHOD.

  METHOD rejectTravel.

    MODIFY ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
  ENTITY travel
  UPDATE FIELDS ( OverallStatus )
  WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                  OverallStatus = 'R'
   ) ).




    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY travel
    ALL FIELDS WITH  CORRESPONDING #( keys )
    RESULT DATA(travels).

    result = VALUE #( FOR travel  IN travels ( %tky = travel-%tky
                                                %param = travel ) ).

  ENDMETHOD.

  METHOD deductDiscount.

    DATA: travel_for_update TYPE TABLE FOR UPDATE  zsa_travel_fin_i .
    DATA(keys_temp) = keys.

    LOOP AT  keys_temp ASSIGNING FIELD-SYMBOL(<key_temp>) WHERE %param-discount_percent IS INITIAL OR
                                                                %param-discount_percent > 100 OR
                                                                %param-discount_percent < 0 .

      APPEND VALUE #( %tky = <key_temp>-%tky  ) TO failed-travel.
      APPEND VALUE #( %tky = <key_temp>-%tky
                      %msg = new_message_with_text( text = 'Invalid Discount Percentage'
                                                     severity = if_abap_behv_message=>severity-error )
                      %element-totalprice = if_abap_behv=>mk-on
                      %action-deductDiscount = if_abap_behv=>mk-on ) TO reported-travel.
      DELETE keys_temp.
    ENDLOOP.

    CHECK keys_temp IS NOT INITIAL.

    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY travel
    FIELDS ( TotalPrice )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels).

    DATA lv_percentage TYPE decfloat16.

    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<fs_travel>).

      DATA(lv_discount_percent) = keys[ KEY id  %tky = <fs_travel>-%tky ]-%param-discount_percent.

      lv_percentage = lv_discount_percent / 100.

      DATA(reduced_value) = <fs_travel>-TotalPrice * lv_percentage .
      reduced_value = <fs_travel>-TotalPrice - reduced_value.

      APPEND VALUE #( %tky = <fs_travel>-%tky
                              totalprice = reduced_value  ) TO travel_for_update.


    ENDLOOP.

    MODIFY ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( TotalPrice )
    WITH travel_for_update.


    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY travel
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(lt_travel_update).

  ENDMETHOD.

  METHOD GetDefaultsFordeductDiscount.

    READ ENTITIES OF zsa_travel_fin_i  IN LOCAL MODE
    ENTITY travel
    FIELDS ( TotalPrice )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).

      IF  travel-TotalPrice >= 4000.
        APPEND VALUE #( %tky = travel-%tky
                        %param-discount_percent = 30 ) TO result.
      ELSE.

        APPEND VALUE #( %tky = travel-%tky
                                %param-discount_percent = 15 ) TO result.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD reCalcTotalprice.

    TYPES:BEGIN OF ty_amount_curncy_code,
            amount       TYPE /dmo/total_price,
            currencycode TYPE /dmo/currency_code,
          END OF ty_amount_curncy_code.

    DATA: amounts_per_currencycode TYPE STANDARD TABLE OF ty_amount_curncy_code.
    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY travel
    FIELDS ( BookingFee CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).


    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY travel BY \_booking
    FIELDS ( FlightPrice CurrencyCode )
    WITH CORRESPONDING #( travels )
    RESULT DATA(bookings)
    LINK DATA(booking_links).

    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY booking BY \_bksuppl
    FIELDS ( Price CurrencyCode )
    WITH CORRESPONDING #( bookings )
    RESULT DATA(bookingsuppliements)
    LINK DATA(bk_suppllinks).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      amounts_per_currencycode = VALUE #( ( amount = <travel>-BookingFee
                                                  currencycode = <travel>-CurrencyCode  ) ).





      LOOP AT booking_links INTO DATA(booking_link) USING KEY id WHERE source-%tky = <travel>-%tky.
        DATA(booking) = bookings[ KEY id %tky = booking_link-target-%tky ].


        COLLECT VALUE ty_amount_curncy_code( amount = booking-FlightPrice
                                                     currencycode = booking-CurrencyCode ) INTO amounts_per_currencycode.


        LOOP AT bk_suppllinks INTO DATA(bk_suppllink) USING KEY id WHERE source-%tky = booking-%tky.

          DATA(bookingsuppliement) = bookingsuppliements[ KEY id %tky = bk_suppllink-target-%tky ].

          COLLECT VALUE ty_amount_curncy_code( amount = bookingsuppliement-Price
                                                         currencycode = bookingsuppliement-CurrencyCode ) INTO amounts_per_currencycode.

        ENDLOOP.

      ENDLOOP.
    ENDLOOP.

    DELETE amounts_per_currencycode WHERE currencycode IS INITIAL.

    LOOP AT amounts_per_currencycode INTO DATA(amount_per_currencycode).

      IF <travel>-CurrencyCode = amount_per_currencycode-currencycode.

        <travel>-TotalPrice += amount_per_currencycode-amount.
      ELSE.

        /dmo/cl_flight_amdp=>convert_currency(
          EXPORTING
            iv_amount               = amount_per_currencycode-amount
            iv_currency_code_source = amount_per_currencycode-currencycode
            iv_currency_code_target = <travel>-CurrencyCode
            iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
          IMPORTING
            ev_amount               = DATA(total_booking_price_per_curr)
        ).


        <travel>-TotalPrice += total_booking_price_per_curr.

      ENDIF.

      MODIFY ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
      ENTITY travel
      UPDATE FIELDS ( TotalPrice  )
      WITH CORRESPONDING #( travels ).

    ENDLOOP.



  ENDMETHOD.

  METHOD calculateTotalPrice.

    MODIFY ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY travel
    EXECUTE reCalcTotalprice
    FROM CORRESPONDING #( keys ).


  ENDMETHOD.

  METHOD validateCustomer.

    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY travel
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    DATA : customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    customers = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING customer_id = CustomerId ).

    SELECT FROM /dmo/customer FIELDS customer_id
    FOR ALL ENTRIES IN @customers
    WHERE customer_id = @customers-customer_id
    INTO TABLE @DATA(valid_customer).
    LOOP AT travels INTO DATA(travel).

      APPEND VALUE #( %tky = travel-%tky
                      %state_area = 'Validate Customer' ) TO reported-travel.

      IF travel-CustomerId IS NOT INITIAL AND NOT line_exists( valid_customer[ customer_id = travel-CustomerId ] ).
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
         %state_area = 'Validate Customer'
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = |'In Valid Customer ' { travel-CustomerId }|
                               )

                        ) TO reported-travel.

      ENDIF.


    ENDLOOP.


  ENDMETHOD.

  METHOD validateAgencyid.
    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
  ENTITY travel
  FIELDS ( AgencyId )
  WITH CORRESPONDING #( keys )
  RESULT DATA(travels).

    DATA : agencyid TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.

    agencyid = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING agency_id = AgencyId ).

    SELECT FROM /dmo/agency FIELDS agency_id
    FOR ALL ENTRIES IN @agencyid
    WHERE agency_id = @agencyid-agency_id
    INTO TABLE @DATA(valid_agencyid).
    LOOP AT travels INTO DATA(travel).

      APPEND VALUE #( %tky = travel-%tky
                            %state_area = 'Validate Agency' ) TO reported-travel.


      IF travel-AgencyId IS NOT INITIAL AND NOT line_exists( valid_agencyid[ agency_id = travel-AgencyId ] ).
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
        %state_area = 'Validate Agency'
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = |'InValid Agent ' { travel-AgencyId }|
                               )

                        ) TO reported-travel.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD validatedates.

    READ ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
ENTITY travel
FIELDS ( BeginDate  EndDate )
WITH CORRESPONDING #( keys )
RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).

      APPEND VALUE #( %tky = travel-%tky
                        %state_area = 'Validate Dates' ) TO reported-travel.


      IF travel-BeginDate IS INITIAL.

        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = travel-%tky

                       %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text = |Begin date should not be blank|
                          )
                       %element-BeginDate = if_abap_behv=>mk-on
                       %state_area = 'Validate Dates'
                       ) TO reported-travel.

      ENDIF.
      IF travel-EndDate IS INITIAL.


        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = travel-%tky

                       %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text = |END date should not be blank |
                          )
                       %element-EndDate = if_abap_behv=>mk-on
                       %state_area = 'Validate Dates'
                       ) TO reported-travel.


      ENDIF.

      IF travel-EndDate < travel-BeginDate AND travel-BeginDate IS NOT INITIAL
                                           AND travel-EndDate IS NOT INITIAL .


        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = travel-%tky

                       %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-error
                       text = |END date should not be less than Begin date |
                          )
                       %element-EndDate = if_abap_behv=>mk-on
                        %element-BeginDate = if_abap_behv=>mk-on
                         %state_area = 'Validate Dates'
                       ) TO reported-travel.



      ENDIF.

    ENDLOOP.
  ENDMETHOD.
*
ENDCLASS.
