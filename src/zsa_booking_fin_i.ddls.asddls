@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds intrfc for booking'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZSA_BOOKING_FIN_I
  as select from zsa_booking_fin
  composition [0..*] of ZSA_BK_SUPP_FIN_I as _bksuppl
  association to parent ZSA_TRAVEL_FIN_I  as _travel on $projection.TravelUuid = _travel.TravelUuid

{
  key booking_uuid          as BookingUuid,
      parent_uuid           as TravelUuid,
      booking_id            as BookingId,
      booking_date          as BookingDate,
      customer_id           as CustomerId,
      carrier_id            as CarrierId,
      connection_id         as ConnectionId,
      flight_date           as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price          as FlightPrice,
      currency_code         as CurrencyCode,
      booking_status        as BookingStatus,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _travel,
      _bksuppl
}
