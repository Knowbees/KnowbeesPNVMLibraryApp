class KohaURLs{

    static const Block = 'prod/';
    static const BaseURL = '/cgi-bin/koha/api-scripts/';

    static const ConfigurationURL = BaseURL+Block+'lib-setup.pl';
    static const NewArrivalURL = BaseURL+Block+'kohaapi-new_arrivals.pl';
    static const SearchScript = BaseURL+Block+'kohaapi-search.pl?';
    static const SearchCategoriesKeys = ['All', 'Title', 'Author', 'Subject'];
    static const ItemSearchCategoriesValues = ['idx=kw&q=', 'idx=ti&q=', 'idx=au&q=', 'idx=su&q='];
    static const BranchCategoryValue = '&branch_group_limit=';
    static const SearchOffset = '&offset=';
    static const SearchSortBy = '&sort_by=relevance_dsc';
    static const DetailsURL = BaseURL+Block+'kohaapi-details.pl';
    static const LoginURL = BaseURL+Block+'kohaapi-login.pl';
    static const IssuedURL = BaseURL+Block+'kohaapi-issued.pl';
    static const PaymentDetailsURL = BaseURL+Block+'kohaapi-payment_details.pl';
    static const ReadingHistoryURL = BaseURL+Block+'kohaapi-reading_history.pl';
    static const SetReserveURL = BaseURL+Block+'kohaapi-set_reserve.pl';
    static const GetReservedURL = BaseURL+Block+'kohaapi-get_reserved.pl';
    static const CancelReservedURL = BaseURL+Block+'kohaapi-cancel_reserved.pl';

    static const BookImageURL = 'https://www.googleapis.com/books/v1/volumes?q=isbn:';
}

