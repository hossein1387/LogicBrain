//==================================================================================================
// Enum: print_verbosity
// Defines standard verbosity levels for reports.
//
//  VERB_NONE    Report is always printed. Verbosity level setting cannot disable it.
//  VERB_LOW     Report is issued if configured verbosity is set to VERB_LOW or above.
//  VERB_MEDIUM  Report is issued if configured verbosity is set to VERB_MEDIUM or above.
//  VERB_HIGH    Report is issued if configured verbosity is set to VERB_HIGH or above.
//  VERB_FULL    Report is issued if configured verbosity is set to VERB_FULL or above.
typedef enum {
    VERB_NONE   = 0,
    VERB_LOW    = 100,
    VERB_MEDIUM = 200,
    VERB_HIGH   = 300,
    VERB_FULL   = 400,
    VERB_DEBUG  = 500
} print_verbosity;
//==================================================================================================
// Struct test_stats
// Defines a struct that holds test statistics 

typedef struct packed
{
    int unsigned pass_cnt;
    int unsigned fail_cnt;
} test_stats;

//==================================================================================================
// Test print macro
// Defines a macro to print 
`define test_print(ID,MSG,VERBOSITY) \
   begin \
     if (VERBOSITY<VERB_MEDIUM) \
       $display("[%5s]  %s ", ID, MSG); \
   end

//==================================================================================================
// Print Banner macro
// Defines a macro to print a banner that bolds the msg
`define print_banner(ID,MSG,VERBOSITY) \
   begin \
      `test_print(ID,"=======================================================================",VERBOSITY) \
      `test_print(ID,MSG,VERBOSITY) \
      `test_print(ID,"=======================================================================",VERBOSITY) \
   end

//==================================================================================================
// A function to report results
function void print_result(test_stats test_stat, print_verbosity verbosity);
    `print_banner("INFO", "Test results", verbosity)
    `test_print("INFO", $sformatf("Number of passed tests = %0d", test_stat.pass_cnt), verbosity)
    `test_print("INFO", $sformatf("Number of failed tests = %0d\n", test_stat.fail_cnt), verbosity)

endfunction : print_result
