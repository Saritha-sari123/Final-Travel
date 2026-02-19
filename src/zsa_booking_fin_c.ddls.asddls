@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption (Projection view)for booking'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION

define view entity ZSA_BOOKING_FIN_C as projection on ZSA_BOOKING_FIN_I
{
    key BookingUuid,
    TravelUuid,
    BookingId,
    BookingDate,
    CustomerId,
    CarrierId,
    ConnectionId,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LocalLastChangedAt,
    /* Associations */
    _bksuppl: redirected to composition child zsa_bk_supp_fin_C,
    _travel: redirected to parent zsa_travel_fin_C
}
