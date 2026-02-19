CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR travel RESULT result.
    METHODS settravelid FOR DETERMINE ON SAVE
      IMPORTING keys FOR travel~settravelid.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD settravelid.


  READ ENTITIES OF ZSA_TRAVEL_FIN_I IN LOCAL MODE
    ENTITY travel
    FIELDS ( TravelId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DELETE lt_travel WHERE TravelId IS NOT INITIAL.

    SELECT SINGLE FROM zsa_travel_fin FIELDS MAX( travel_id ) INTO @DATA(lv_travelid_max).

    MODIFY ENTITIES OF ZSA_TRAVEL_FIN_I IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( TravelId )
    WITH VALUE #( FOR ls_travel_id IN lt_travel INDEX INTO lv_index
                       ( %tky = ls_travel_id-%tky
                        TravelId = lv_travelid_max + lv_index ) ).



  ENDMETHOD.

ENDCLASS.
