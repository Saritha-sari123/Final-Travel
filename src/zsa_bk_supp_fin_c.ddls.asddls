@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption (Projection view)for bksupp'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION

define view entity ZSA_BK_SUPP_FIN_C as projection on ZSA_BK_SUPP_FIN_I
{
    key BooksuppUuid,
    TravelUuid,
    BookingUuid,
    BookingSupplementId,
    SupplementId,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    LocalLastChangedAt,
    /* Associations */
    _booking:redirected to parent zsa_booking_fin_C,
    _travel: redirected to zsa_travel_fin_C
}
