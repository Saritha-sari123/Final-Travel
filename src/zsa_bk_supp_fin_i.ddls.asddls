@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Bksupp cds view entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSA_BK_SUPP_FIN_I as select from zsa_bk_supp_fin

association to parent ZSA_BOOKING_FIN_I as _booking on $projection.BookingUuid = _booking.BookingUuid
association [1] to ZSA_TRAVEL_FIN_I as _travel on $projection.TravelUuid = _travel.TravelUuid
{
    key booksupp_uuid as BooksuppUuid,
    root_uuid as TravelUuid,
    parent_uuid as BookingUuid,
    booking_supplement_id as BookingSupplementId,
    supplement_id as SupplementId,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    price as Price,
    currency_code as CurrencyCode,
     @Semantics.systemDateTime.localInstanceLastChangedAt: true
    local_last_changed_at as LocalLastChangedAt,
    _travel,
    _booking
}
