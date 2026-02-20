CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS setbookingdate FOR DETERMINE ON SAVE
      IMPORTING keys FOR booking~setbookingdate.

    METHODS setbookingid FOR DETERMINE ON SAVE
      IMPORTING keys FOR booking~setbookingid.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD setbookingdate.
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

    READ ENTITIES OF  zsa_travel_fin_i IN LOCAL MODE
    ENTITY travel BY \_booking
    FIELDS ( BookingId )
    WITH CORRESPONDING #( keys )
    LINK DATA(booking_links)
    RESULT DATA(bookings).


    LOOP AT travels INTO DATA(travel).

      max_bookingid = '0000'.

      LOOP AT booking_links INTO DATA(booking_link) USING KEY id WHERE source-%tky = travel-%tky.

        booking = bookings[ KEY id
                          %tky = booking_link-target-%tky ].

        IF booking-BookingId > max_bookingid.
          max_bookingid = booking-BookingId.

        ENDIF.
      ENDLOOP.

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
    " use modify eml to update the booking entity with the new booking id num which is max_bookingid

    MODIFY ENTITIES OF zsa_travel_fin_i IN LOCAL MODE
    ENTITY booking
    UPDATE FIELDS ( BookingId )
    WITH bookings_update.



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

ENDCLASS.
