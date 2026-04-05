import 'package:flutter/material.dart';
import 'en.dart';
import 'vi.dart';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  final Map<String, String> _localizedStrings;

  AppLocalizations(this._localizedStrings);

  String translate(String key) => _localizedStrings[key] ?? key;

  String get example => translate('example');

  // Auth
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirmPassword');
  String get login => translate('login');
  String get register => translate('register');
  String get logout => translate('logout');
  String get forgotPassword => translate('forgotPassword');
  String get resetPassword => translate('resetPassword');
  String get signUp => translate('signUp');
  String get signIn => translate('signIn');
  String get signInWithGoogle => translate('signInWithGoogle');
  String get signInWithFacebook => translate('signInWithFacebook');
  String get alreadyHaveAccount => translate('alreadyHaveAccount');
  String get dontHaveAccount => translate('dontHaveAccount');
  String get invalidEmail => translate('invalidEmail');
  String get passwordTooShort => translate('passwordTooShort');
  String get passwordsDoNotMatch => translate('passwordsDoNotMatch');
  String get emailAlreadyExists => translate('emailAlreadyExists');
  String get invalidCredentials => translate('invalidCredentials');
  String get loginSuccess => translate('loginSuccess');
  String get registerSuccess => translate('registerSuccess');
  String get logoutSuccess => translate('logoutSuccess');
  String get emailAddressHint => translate('emailAddressHint');
  String get passwordHint => translate('passwordHint');
  String get rememberMe => translate('rememberMe');
  String get welcomeBack => translate('welcomeBack');
  String get signInToContinue => translate('signInToContinue');
  String get dontHaveAccountQuestion => translate('dontHaveAccountQuestion');
  String get loginError => translate('loginError');
  String get emailRequired => translate('emailRequired');
  String get invalidEmailFormat => translate('invalidEmailFormat');
  String get passwordRequired => translate('passwordRequired');

  // Profile
  String get profile => translate('profile');
  String get editProfile => translate('editProfile');
  String get fullName => translate('fullName');
  String get phoneNumber => translate('phoneNumber');
  String get address => translate('address');
  String get bio => translate('bio');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get close => translate('close');
  String get edit => translate('edit');
  String get info => translate('info');
  String get favorites => translate('favorites');
  String get profileUpdated => translate('profileUpdated');
  String get messagesTitle => translate('messagesTitle');
  String get fromRecruiters => translate('fromRecruiters');
  String get searchMessagesHint => translate('searchMessagesHint');
  String get unreadFilter => translate('unreadFilter');
  String get urgentFilter => translate('urgentFilter');
  String get interviewedFilter => translate('interviewedFilter');
  String get savedFilter => translate('savedFilter');
  String get pinnedLabel => translate('pinnedLabel');
  String get allLabel => translate('allLabel');
  String get respondsIn24h => translate('respondsIn24h');
  String get resume => translate('resume');
  String get uploadResume => translate('uploadResume');
  String get replaceResume => translate('replaceResume');
  String get deleteResume => translate('deleteResume');
  String get viewResume => translate('viewResume');
  String get skills => translate('skills');
  String get experience => translate('experience');
  String get education => translate('education');
  String get resumeDocuments => translate('resumeDocuments');
  String get resumeFiles => translate('resumeFiles');
  String get browseFiles => translate('browseFiles');
  String get uploadThankYou => translate('uploadThankYou');
  String get uploadFailed => translate('uploadFailed');
  String get replaceFailed => translate('replaceFailed');
  String get deleteSuccess => translate('deleteSuccess');
  String get setDefaultSuccess => translate('setDefaultSuccess');
  String get replaceSuccess => translate('replaceSuccess');

  // Jobs
  String get jobs => translate('jobs');
  String get jobTitle => translate('jobTitle');
  String get company => translate('company');
  String get location => translate('location');
  String get salary => translate('salary');
  String get description => translate('description');
  String get requirements => translate('requirements');
  String get applyJob => translate('applyJob');
  String get appliedJobs => translate('appliedJobs');
  String get savedJobs => translate('savedJobs');
  String get jobDetails => translate('jobDetails');
  String get noJobsFound => translate('noJobsFound');
  String get applySuccess => translate('applySuccess');
  String get apply => translate('apply');
  String get favoriteJobs => translate('favoriteJobs');

  // Common
  String get home => translate('home');
  String get search => translate('search');
  String get settings => translate('settings');
  String get language => translate('language');
  String get selectLanguage => translate('selectLanguage');
  String get notifications => translate('notifications');
  String get help => translate('help');
  String get about => translate('about');
  String get version => translate('version');
  String get loading => translate('loading');
  String get error => translate('error');
  String get errorMessage => translate('errorMessage');
  String get success => translate('success');
  String get tryAgain => translate('tryAgain');
  String get noInternetConnection => translate('noInternetConnection');
  String get somethingWentWrong => translate('somethingWentWrong');
  String get open => translate('open');
  String get yes => translate('yes');
  String get no => translate('no');
  String get ok => translate('ok');
  String get contactUs => translate('contactUs');
  String get privacyPolicy => translate('privacyPolicy');
  String get termsOfService => translate('termsOfService');
  String get helpCenter => translate('helpCenter');
  String get changePassword => translate('changePassword');
  String get pushNotifications => translate('pushNotifications');
  String get account => translate('account');
  String get privacy => translate('privacy');
  String get support => translate('support');
  String get desiredPosition => translate('desiredPosition');
  String get yearsOfExperience => translate('yearsOfExperience');
  String get positionDesiredTitle => translate('positionDesiredTitle');
  String get exitApplication => translate('exitApplication');
  String get coverLetter => translate('coverLetter');
  String get applySuccessMessage => translate('applySuccessMessage');
  String get stepOfThree => translate('stepOfThree');
  String get chooseYourRole => translate('chooseYourRole');
  String get selectHowToUse => translate('selectHowToUse');
  String get iAmCandidate => translate('iAmCandidate');
  String get candidateDescription => translate('candidateDescription');
  String get iAmEmployer => translate('iAmEmployer');
  String get employerDescription => translate('employerDescription');
  String get next => translate('next');
  String get back => translate('back');
  String get selectRole => translate('selectRole');
  String get uploadNewResume => translate('uploadNewResume');
  String get uploadFileSize => translate('uploadFileSize');
  String get fullNameHint => translate('fullNameHint');
  String get fullNameRequired => translate('fullNameRequired');
  String get fullNameLength => translate('fullNameLength');
  String get emailAddressRequired => translate('emailAddressRequired');
  String get passwordMinLength => translate('passwordMinLength');
  String get confirmPasswordLabel => translate('confirmPasswordLabel');
  String get confirmPasswordHint => translate('confirmPasswordHint');
  String get passwordMismatch => translate('passwordMismatch');
  String get stepOfThreeMsg => translate('stepOfThreeMsg');
  String get otpVerification => translate('otpVerification');
  String get emailVerificationMessage => translate('emailVerificationMessage');
  String get clickLinkMessage => translate('clickLinkMessage');
  String get confirmedEmail => translate('confirmedEmail');
  String get didNotReceiveEmail => translate('didNotReceiveEmail');
  String get resendEmail => translate('resendEmail');
  String get requestNewCode => translate('requestNewCode');
  String get verificationSuccess => translate('verificationSuccess');
  String get verificationFailed => translate('verificationFailed');
  String get resendFailed => translate('resendFailed');

  // Job Search & Details
  String get searchJobTitle => translate('searchJobTitle');
  String get clearFilters => translate('clearFilters');
  String get noJobsMatch => translate('noJobsMatch');
  String get jobsFound => translate('jobsFound');
  String get mostRelevant => translate('mostRelevant');
  String get alreadyApplied => translate('alreadyApplied');
  String get applyNow => translate('applyNow');
  String get jobClosed => translate('jobClosed');

  // Apply Job
  String get applyForJob => translate('applyForJob');
  String get cancelButton => translate('cancelButton');
  String get selectCV => translate('selectCV');
  String get chooseResumeForApplication =>
      translate('chooseResumeForApplication');
  String get noCVFound => translate('noCVFound');
  String get pleaseUploadCVBeforeApplying =>
      translate('pleaseUploadCVBeforeApplying');
  String get resumeSelection => translate('resumeSelection');
  String get finalReview => translate('finalReview');
  String get step1Of2 => translate('step1Of2');
  String get step2Of2 => translate('step2Of2');
  String get readyToApplyStatus => translate('readyToApplyStatus');
  String get optionalLabel => translate('optionalLabel');
  String get goToProfile => translate('goToProfile');
  String get coverLetterPlaceholder => translate('coverLetterPlaceholder');
  String get reviewSelectedCvTitle => translate('reviewSelectedCvTitle');
  String get attachedToApplicationStatus =>
      translate('attachedToApplicationStatus');
  String get changeCvButton => translate('changeCvButton');
  String get submitApplicationButton => translate('submitApplicationButton');
  String get submittingButton => translate('submittingButton');
  String get termsAgreement => translate('termsAgreement');
  String get applicationSentSuccess => translate('applicationSentSuccess');
  String get applicationReceivedMessage =>
      translate('applicationReceivedMessage');
  String get hasBeenReceived => translate('hasBeenReceived');
  String get atLabel => translate('atLabel');
  String get viewApplicationStatusButton =>
      translate('viewApplicationStatusButton');
  String get backToHomeButton => translate('backToHomeButton');
  String get nextButton => translate('nextButton');

  // Home Page
  String get homePageTitle => translate('homePageTitle');
  String get dashboardTooltip => translate('dashboardTooltip');
  String get recommendedJobsTitle => translate('recommendedJobsTitle');
  String get recentJobPostingsTitle => translate('recentJobPostingsTitle');
  String get searchResultsTitle => translate('searchResultsTitle');
  String get noJobsFoundMessage => translate('noJobsFoundMessage');
  String get loadMoreButton => translate('loadMoreButton');

  // Interview Schedule
  String get interviewScheduleTitle => translate('interviewScheduleTitle');
  String get noInterviewsMessage => translate('noInterviewsMessage');
  String get statusAccepted => translate('statusAccepted');
  String get statusRejected => translate('statusRejected');
  String get statusReschedule => translate('statusReschedule');
  String get statusPending => translate('statusPending');
  String get declineButton => translate('declineButton');
  String get rescheduleButton => translate('rescheduleButton');
  String get acceptButton => translate('acceptButton');
  String get scheduleConfirmedMessage => translate('scheduleConfirmedMessage');
  String get scheduleDeclinedMessage => translate('scheduleDeclinedMessage');
  String get rescheduleRequestedMessage =>
      translate('rescheduleRequestedMessage');
  String get contactLabel => translate('contactLabel');
  String get noLocationText => translate('noLocationText');
  String get notAvailable => translate('notAvailable');

  // Applications Page
  String get applicationHistoryTitle => translate('applicationHistoryTitle');
  String get appliedTabLabel => translate('appliedTabLabel');
  String get interviewsTabLabel => translate('interviewsTabLabel');
  String get acceptedTabLabel => translate('acceptedTabLabel');
  String get couldNotLoadProfileMessage =>
      translate('couldNotLoadProfileMessage');
  String get retryButton => translate('retryButton');
  String get noApplicationsFoundMessage =>
      translate('noApplicationsFoundMessage');
  String get noApplicationsFoundDescription =>
      translate('noApplicationsFoundDescription');
  String get appliedOnLabel => translate('appliedOnLabel');
  String get withdrawButton => translate('withdrawButton');
  String get withdrawConfirmTitle => translate('withdrawConfirmTitle');
  String get withdrawConfirmMessage => translate('withdrawConfirmMessage');
  String get withdrawSuccessMessage => translate('withdrawSuccessMessage');
  String get withdrawFailureMessage => translate('withdrawFailureMessage');

  // Messages Page
  String get messagesPageTitle => translate('messagesPageTitle');
  String get fromEmployersSubtitle => translate('fromEmployersSubtitle');
  String get messageSearchPlaceholder => translate('messageSearchPlaceholder');
  String get unreadFilterLabel => translate('unreadFilterLabel');
  String get urgentHiringFilterLabel => translate('urgentHiringFilterLabel');
  String get interviewedFilterLabel => translate('interviewedFilterLabel');
  String get savedFilterLabel => translate('savedFilterLabel');
  String get pinnedSectionLabel => translate('pinnedSectionLabel');
  String get allSectionLabel => translate('allSectionLabel');
  String get respondWithin24hTag => translate('respondWithin24hTag');
  String get pinnedTag => translate('pinnedTag');

  // Welcome Page
  String get welcomeTitle => translate('welcomeTitle');
  String get welcomeDescription => translate('welcomeDescription');

  // Forgot Password
  String get checkEmailTitle => translate('checkEmailTitle');
  String get otpSentMessage => translate('otpSentMessage');
  String get enterOtpPlaceholder => translate('enterOtpPlaceholder');
  String get verifyOtpButton => translate('verifyOtpButton');
  String get insufficientOtpError => translate('insufficientOtpError');
  String get invalidOtpError => translate('invalidOtpError');
  String get expiredOtpError => translate('expiredOtpError');
  String get otpResendMessage => translate('otpResendMessage');
  String get resendButton => translate('resendButton');
  String get otpResentSuccess => translate('otpResentSuccess');
  String get resendFailure => translate('resendFailure');
  String get successfullyApplied => translate('successfullyApplied');
  String get applicationFailed => translate('applicationFailed');
  String get applicationSuccessMessage =>
      translate('applicationSuccessMessage');
  String get mustAddCVBeforeApplying => translate('mustAddCVBeforeApplying');

  // Employer Flow
  String get employerDashboard => translate('employerDashboard');
  String get overview => translate('overview');
  String get last30Days => translate('last30Days');
  String get activeJobs => translate('activeJobs');
  String get applicants => translate('applicants');
  String get interviewsCount => translate('interviewsCount');
  String get recentActivities => translate('recentActivities');
  String get viewAll => translate('viewAll');
  String get manageJobs => translate('manageJobs');
  String get noJobsYet => translate('noJobsYet');
  String get createFirstJobPost => translate('createFirstJobPost');
  String get postNewJob => translate('postNewJob');
  String get needToHire => translate('needToHire');
  String get postNewJobDescription => translate('postNewJobDescription');
  String get draftJobs => translate('draftJobs');
  String get closedJobs => translate('closedJobs');
  String get allJobs => translate('allJobs');
  String get activeStatus => translate('activeStatus');
  String get closedStatus => translate('closedStatus');
  String get draftStatus => translate('draftStatus');
  String get pendingStatus => translate('pendingStatus');
  String get untitledJob => translate('untitledJob');
  String get viewApplicants => translate('viewApplicants');
  String get viewHistory => translate('viewHistory');
  String get reopen => translate('reopen');
  String get reopenJobTitle => translate('reopenJobTitle');
  String get reopenJobConfirm => translate('reopenJobConfirm');
  String get deleteJobTitle => translate('deleteJobTitle');
  String get deleteJobConfirm => translate('deleteJobConfirm');
  String get closeJobTitle => translate('closeJobTitle');
  String get closeJobConfirm => translate('closeJobConfirm');
  String get jobReopenedSuccess => translate('jobReopenedSuccess');
  String get jobDeleted => translate('jobDeleted');
  String get jobClosedSuccess => translate('jobClosedSuccess');
  String get noJobsInTab => translate('noJobsInTab');
  String get tryCreatingNewJob => translate('tryCreatingNewJob');
  String get boostFeatureComingSoon => translate('boostFeatureComingSoon');
  String get couldNotLoadJobs => translate('couldNotLoadJobs');
  String get editJob => translate('editJob');
  String get postANewJob => translate('postANewJob');
  String get reviewJobChanges => translate('reviewJobChanges');
  String get previewJobPost => translate('previewJobPost');
  String get confirmAndPost => translate('confirmAndPost');
  String get publishJob => translate('publishJob');
  String get updateJob => translate('updateJob');
  String get backToEdit => translate('backToEdit');
  String get addAnotherJob => translate('addAnotherJob');
  String get saveDraft => translate('saveDraft');
  String get previewJob => translate('previewJob');
  String get nextStep => translate('nextStep');
  String get jobTitleRequired => translate('jobTitleRequired');
  String get pleaseChooseCategory => translate('pleaseChooseCategory');
  String get locationRequired => translate('locationRequired');
  String get descriptionRequired => translate('descriptionRequired');
  String get requirementsRequired => translate('requirementsRequired');
  String get employmentTypeRequired => translate('employmentTypeRequired');
  String get positionsGreaterThanZero => translate('positionsGreaterThanZero');
  String get chooseDeadline => translate('chooseDeadline');
  String get addSalaryRange => translate('addSalaryRange');
  String get jobTitleDraftRequired => translate('jobTitleDraftRequired');
  String get jobUpdatedSuccess => translate('jobUpdatedSuccess');
  String get jobPostedSuccess => translate('jobPostedSuccess');
  String get draftSavedSuccess => translate('draftSavedSuccess');
  String get selectCategory => translate('selectCategory');
  String get jobTitleExampleHint => translate('jobTitleExampleHint');
  String get experienceExampleHint => translate('experienceExampleHint');
  String get softwareDevelopment => translate('softwareDevelopment');
  String get designCreative => translate('designCreative');
  String get productManagement => translate('productManagement');
  String get dataScienceAnalytics => translate('dataScienceAnalytics');
  String get devOpsInfrastructure => translate('devOpsInfrastructure');
  String get marketingGrowth => translate('marketingGrowth');
  String get salesBusinessDevelopment => translate('salesBusinessDevelopment');
  String get humanResources => translate('humanResources');
  String get financeAccounting => translate('financeAccounting');
  String get operationsAdministration => translate('operationsAdministration');
  String get negotiable => translate('negotiable');
  String get openPositions => translate('openPositions');
  String get opening => translate('opening');
  String get openings => translate('openings');
  String get applicationDeadline => translate('applicationDeadline');
  String get selectDate => translate('selectDate');
  String get perksAndBenefits => translate('perksAndBenefits');
  String get noBenefitsAddedYet => translate('noBenefitsAddedYet');
  String get includedBenefit => translate('includedBenefit');
  String get salaryRange => translate('salaryRange');
  String get minSalary => translate('minSalary');
  String get maxSalary => translate('maxSalary');
  String get fromSalary => translate('fromSalary');
  String get upToSalary => translate('upToSalary');
  String get perMonth => translate('perMonth');
  String get jobDescription => translate('jobDescription');
  String get jobRequirements => translate('jobRequirements');
  String get noDescriptionProvidedYet => translate('noDescriptionProvidedYet');
  String get noRequirementsListedYet => translate('noRequirementsListedYet');
  String get skillsAndTags => translate('skillsAndTags');
  String get addSkillHint => translate('addSkillHint');
  String get employmentType => translate('employmentType');
  String get fullTime => translate('fullTime');
  String get partTime => translate('partTime');
  String get contract => translate('contract');
  String get freelance => translate('freelance');
  String get internship => translate('internship');
  String get remote => translate('remote');
  String get addSkills => translate('addSkills');
  String get addCustom => translate('addCustom');
  String get customSkillComingSoon => translate('customSkillComingSoon');
  String get figma => translate('figma');
  String get uiDesign => translate('uiDesign');
  String get flutter => translate('flutter');
  String get react => translate('react');
  String get communication => translate('communication');
  String get leadership => translate('leadership');
  String get healthInsurance => translate('healthInsurance');
  String get gym => translate('gym');
  String get bonus => translate('bonus');
  String get remoteWork => translate('remoteWork');
  String get paidLeave => translate('paidLeave');
  String get flexibleHours => translate('flexibleHours');
  String get stockOptions => translate('stockOptions');
  String get unknownCompany => translate('unknownCompany');
  String get locationNotSet => translate('locationNotSet');
  String get verified => translate('verified');
  String get readyToPublish => translate('readyToPublish');
  String get missing => translate('missing');
  String get statusDraft => translate('statusDraft');
  String get statusClosed => translate('statusClosed');
  String get statusActive => translate('statusActive');
  String get jobPendingStatus => translate('pendingStatus');
  String get couldNotSaveJob => translate('couldNotSaveJob');
  String get experienceLevel => translate('experienceLevel');
  String get entryLevel => translate('entryLevel');
  String get midLevel => translate('midLevel');
  String get seniorLevel => translate('seniorLevel');
  String get leadLevel => translate('leadLevel');
  String get clearAll => translate('clearAll');
  String get showResults => translate('showResults');
  String get enterLocationHint => translate('enterLocationHint');
  String get filters => translate('filters');
  String get jobSaved => translate('jobSaved');
  String get addedToFavorites => translate('addedToFavorites');
  String get applicantsSoFar => translate('applicantsSoFar');
  String get resumePreview => translate('resumePreview');
  String get filesCount => translate('filesCount');
  String get replacedSuccess => translate('replacedSuccess');
  String get couldNotOpenUrl => translate('couldNotOpenUrl');
  String get uploadedLabel => translate('uploadedLabel');
  String get applicationTimeline => translate('applicationTimeline');
  String get applicationSubmitted => translate('applicationSubmitted');
  String get underReview => translate('underReview');
  String get shortlistedInterview => translate('shortlistedInterview');
  String get decision => translate('decision');
  String get yourApplication => translate('yourApplication');
  String get attachedResume => translate('attachedResume');
  String get withdrawConfirmMessageUndo =>
      translate('withdrawConfirmMessageUndo');
  String get pendingReview => translate('pendingReview');
  String get employerReviewing => translate('employerReviewing');
  String get interviewInvited => translate('interviewInvited');
  String get acceptedHired => translate('acceptedHired');
  String get notSelected => translate('notSelected');
  String get withdrawnByYou => translate('withdrawnByYou');
  String get currentStatus => translate('currentStatus');
  String get applicationStatus => translate('applicationStatus');
  String get negotiableSubtitle => translate('negotiableSubtitle');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    late Map<String, String> localizedStrings;

    if (locale.languageCode == 'vi') {
      localizedStrings = vietStrings;
    } else {
      localizedStrings = englishStrings;
    }

    return AppLocalizations(localizedStrings);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
