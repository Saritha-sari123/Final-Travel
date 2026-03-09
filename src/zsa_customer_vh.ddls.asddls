@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer value help'
@Metadata.ignorePropagatedAnnotations: true


@ObjectModel.resultSet.sizeCategory: #XS
define view entity Zsa_Customer_VH 
as select from /DMO/I_Customer
{
    key CustomerID,
    FirstName,
    LastName,
    Title,
    Street,
    PostalCode,
    City,
    CountryCode,
    PhoneNumber,
    EMailAddress,
    /* Associations */
    _Country
}
