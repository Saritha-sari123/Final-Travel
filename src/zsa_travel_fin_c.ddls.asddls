@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption (Projection view)for travel'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@VDM.viewType: #CONSUMPTION

define root view entity ZSA_TRAVEL_FIN_C
  provider contract transactional_query as projection on ZSA_TRAVEL_FIN_I
{
    key TravelUuid,
    TravelId,
    AgencyId,
    CustomerId,
    BeginDate,
    EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalPrice,
    CurrencyCode,
    Description,
    OverallStatus,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _booking:redirected to composition child zsa_booking_fin_C
}
