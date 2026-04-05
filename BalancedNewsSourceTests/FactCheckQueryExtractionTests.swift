import XCTest
@testable import BalancedNewsSource

/// Tests that verify the focused-query extraction produces tighter, more searchable
/// terms compared to the original full-title approach.
///
/// Each test case shows:
///   - `original`  — what the old code sent to the API (the raw headline)
///   - `extracted` — what the new code sends (stopwords stripped, ≤6 key terms)
///
/// A "better" query is shorter, contains only meaningful nouns/entities, and avoids
/// filler words that dilute precision in the Google Fact Check Tools API.
final class FactCheckQueryExtractionTests: XCTestCase {

    // MARK: - Helpers

    private func extracted(_ title: String) -> String {
        FactCheckService.extractQuery(from: title)
    }

    // MARK: - Query Extraction

    func test_earthquake_headline() {
        let original  = "Earthquake jolts J&K, tremors felt across North India"
        let result    = extracted(original)

        // Should keep the key geographic/event terms and drop filler
        XCTAssertTrue(result.contains("earthquake"),  "should keep 'earthquake'")
        XCTAssertTrue(result.contains("j&k"),         "should keep 'J&K' entity")
        XCTAssertTrue(result.contains("north india"), "should keep 'North India'")
        XCTAssertFalse(result.contains("jolts"),      "headline filler 'jolts' should be stripped")
        XCTAssertFalse(result.contains("felt"),       "filler 'felt' should be stripped")
        XCTAssertFalse(result.contains("across"),     "stopword 'across' should be stripped")

        // Focused query must be shorter than the original
        XCTAssertLessThan(result.count, original.count)
    }

    func test_modi_headline() {
        let original = "PM Modi says economy growing at fastest pace"
        let result   = extracted(original)

        XCTAssertTrue(result.contains("pm"),          "should keep 'PM'")
        XCTAssertTrue(result.contains("modi"),        "should keep named entity 'Modi'")
        XCTAssertTrue(result.contains("economy"),     "should keep 'economy'")
        XCTAssertFalse(result.contains("says"),       "news filler 'says' should be stripped")
        XCTAssertFalse(result.contains("at"),         "stopword 'at' should be stripped")
    }

    func test_election_headline() {
        let original = "BJP wins majority in Rajasthan assembly elections, says party chief"
        let result   = extracted(original)

        XCTAssertTrue(result.contains("bjp"),           "should keep party name")
        XCTAssertTrue(result.contains("rajasthan"),     "should keep state name")
        XCTAssertFalse(result.contains("says"),         "filler 'says' should be stripped")
        XCTAssertFalse(result.contains("in"),           "stopword 'in' should be stripped")

        let wordCount = result.split(separator: " ").count
        XCTAssertLessThanOrEqual(wordCount, 6, "query should contain at most 6 words")
    }

    func test_max_six_words() {
        let longTitle = "India China Border Tension Rises Again As Troops Mass Near LAC In Eastern Ladakh"
        let result    = extracted(longTitle)
        let wordCount = result.split(separator: " ").count
        XCTAssertLessThanOrEqual(wordCount, 6, "must cap at 6 key terms")
    }

    func test_internal_ampersand_preserved() {
        // J&K is a well-known entity; the & must survive stripping
        let result = extracted("Violence erupts in J&K border district")
        XCTAssertTrue(result.contains("j&k"), "& inside an entity like J&K should be preserved")
    }

    func test_short_title_unchanged_length() {
        // A very short title with no stopwords should pass through intact
        let title  = "India Pakistan ceasefire"
        let result = extracted(title)
        XCTAssertTrue(result.contains("india"),    "should keep 'india'")
        XCTAssertTrue(result.contains("pakistan"), "should keep 'pakistan'")
        XCTAssertTrue(result.contains("ceasefire"),"should keep 'ceasefire'")
    }

    // MARK: - Endpoint Parameters

    func test_endpoint_includes_language_code() {
        let url = Endpoint.factCheck(query: "test query")
        let components = URLComponents(url: url!, resolvingAgainstBaseURL: false)!
        let langItem = components.queryItems?.first(where: { $0.name == "languageCode" })
        XCTAssertEqual(langItem?.value, "en", "languageCode=en should always be present")
    }

    func test_endpoint_with_publisher_filter() {
        let url = Endpoint.factCheck(query: "test", reviewPublisherSiteFilter: "boomlive.in")
        let components = URLComponents(url: url!, resolvingAgainstBaseURL: false)!
        let filterItem = components.queryItems?.first(where: { $0.name == "reviewPublisherSiteFilter" })
        XCTAssertEqual(filterItem?.value, "boomlive.in")
    }

    func test_endpoint_without_publisher_filter() {
        let url = Endpoint.factCheck(query: "test")
        let components = URLComponents(url: url!, resolvingAgainstBaseURL: false)!
        let filterItem = components.queryItems?.first(where: { $0.name == "reviewPublisherSiteFilter" })
        XCTAssertNil(filterItem, "no filter item should be present when not specified")
    }

    // MARK: - Indian Fact-Checker Coverage

    func test_indian_factcheckers_list_contains_expected_sites() {
        let sites = FactCheckService.indianFactCheckers
        XCTAssertTrue(sites.contains("boomlive.in"),     "Boom Live is IFCN-certified")
        XCTAssertTrue(sites.contains("altnews.in"),      "Alt News is IFCN-certified")
        XCTAssertTrue(sites.contains("factchecker.in"),  "FactChecker.in is IFCN-certified")
        XCTAssertTrue(sites.contains("vishvasnews.com"), "Vishvas News is IFCN-certified")
        XCTAssertTrue(sites.contains("newschecker.in"),  "NewChecker is IFCN-certified")
    }

    func test_indian_factcheckers_list_is_not_empty() {
        XCTAssertFalse(FactCheckService.indianFactCheckers.isEmpty)
    }
}
