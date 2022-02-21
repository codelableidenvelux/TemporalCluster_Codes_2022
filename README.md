# Temporal clusters of age-related behavioral alterations captured in smartphone touchscreen interactions
---
## Ceolini E. , Kock R. , Stoet G. , Band G. , Ghosh A.
---
This is the code used to produce the results of the paper. When using any parts of this code please cite it.
---

|Overall numbers report        			| Total |Age study|Other studies|
|-----------------------------------|-------|---------|-------------|
|Subjects recruited            			|  720   |552| 168|             |
|Subjects with phone data      			| 642   |479| 163|               |


Subjects with reported gender:		  631 (235 male, 396 female)     
Subjects with at least 7 days and at least 100 taps  598
Subject with finger test                             250

TOTAL TAPS: 355968131

Gender:
  1 = male
  2 = female

### List of datasets

- [all_single_jids_age_gender_mf_th_v14](all_single_jids_age_gender_mf_th_v14.mat) : Table containing the data needed to run the global age analysis (see [age_analysis.m](age_analysis.m)) and some supplementary analysis (see [extra_analysis.m](extra_analysis.m)), the table contains the following information for each of the 598 subjects:
  - partId: unique identifier from QuantActions.
  - jids: 4 50-by-50 matrices corresponding to the JIDs (Full, Launcher, Social, Transition) accumulated over the full recording period.
  - age
  - n_taps: total number of taps in the full recording period
  - gender
  - median(usage): median number of taps per days (excluding days with no taps)
  - n_days: total number of days of the full recording period
  - rtime: results of one reaction time task
  - 2back: results of one 2back task
  - taskswitch: results of one task switch task
  - corsi: results of one corsi block task
  - sf36: results of the sf36 questionnaire
  - finger: finger preference when using phone + number of years of experience  
  - n_tests: number of cognitive tests available from the subject
  - screen_size: size of the smartphone screen in inches


- Datasets for the cognitive tests results (see [psytest_analysis.m](psytest_analysis.m)) and some supplementary analysis (see [extra_analysis.m](extra_analysis.m)). Here we have separated datasets for each cognitive test since the corresponding JIDs are obtained by accumutaing a window of +/- 10 days around the test time.
  - [data_proc_2back](data_proc_2back.mat)
  - [data_proc_corsi](data_proc_corsi.mat)
  - [data_proc_rtime](data_proc_rtime.mat)
  - [data_proc_switch](data_proc_switch.mat)
  - [jids_finger_v13](jids_finger_v13.mat)

Each dataset contains 14 columns:
  - partId: unique identifier from QuantActions.
  - psyId: unique identifier from PsyToolkit.
  - testName: name of the test.
  - session: index of the sessions extracted
  - jids: 4 50-by-50 matrices corresponding to the JIDs (Full, Launcher, Social, Transition) accumulated over +/- 10 days around test time
  - vals: values of the test (see Methods section for more info about these values)
  - n_taps: total number of taps in the accumulation window
  - age
  - gender
  - n_presentatuions: number of presentations in the test
  - n_days: total number of days of the accumulation window
  - usage: median number of taps per days (excluding days with no taps)
  - entropy: Entropy of the full JID
  - screen_size: size of the smartphone screen in inches


### Models used in the various figures:

- Figure 2
  - Unique model:
    **log10(pixel + 3.1463e-12) = test + gender + c**

- Figure 3
  - Unique model:
    l**og10(pixel + 3.1463e-12) = age + gender + c**
  - Supplementary: unique model
	 - x_iii:   **Entropy = Age + Gender + c**
	 - x_ii:    **log10(pixel + 3.1463e-12) = age + gender + log10(median(usage) + 1e-15)**
	 - x_i:     **log10(median(usage) + 1e-15) = age + gender + c**

- Figure 4
  - Multistage: First gender regressing value (test or pixel) and then age regressing residual from gender
    **log10(pixel + 3.1463e-12) = age + gender + c
    test = age + gender + c** (_Note: We report t/p/f/r2 values of the second regression the one regressing age on the gender residuals_)

- Figure 5
  - Multistage: First gender regressing test and then age regressing residual from gender
    **test = age + gender + c** (_Note: We report t/p/f/r2 values of the second regression the one regressing age on the gender residuals_)
  - Supplementary a.i gender t and p values for gender are obtained from a different multivariate model **test = age + gender + c**
