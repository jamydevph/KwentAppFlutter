class Strings {
  const Strings._();

  static const appName = 'Kwentapp';
  static const tagline = 'Where stories get told';

  static const signIn = 'Sign In';
  static const signUp = 'Sign Up';
  static const logOut = 'Log out';
  static const welcomeBack = 'Welcome back';
  static const createAccount = 'Create account';
  static const createAccountSubtitle = 'Start telling your kwento';
  static const nameLabel = 'Name';
  static const emailLabel = 'Email';
  static const passwordLabel = 'Password';
  static const nameHint = 'Juan dela Cruz';
  static const emailHint = 'you@email.com';
  static const passwordHint = 'At least 8 characters';
  static const noAccountYet = 'No account yet?';
  static const alreadyHaveAccount = 'Already have an account?';
  static const termsNote =
      'By signing up, you agree to our Terms of Service and Privacy Policy.';
  static const showPassword = 'Show password';
  static const hidePassword = 'Hide password';
  static const authNotWiredYet =
      'Form validated. Sign-in is wired once Supabase is set up (Day 10).';

  static const nameRequired = 'Please enter your name';
  static const emailRequired = 'Please enter your email';
  static const emailInvalid = 'Please enter a valid email address';
  static const passwordRequired = 'Please enter your password';
  static const passwordTooShort = 'Password must be at least 8 characters';

  static const invalidCredentials = 'Incorrect email or password';
  static const notAllowed = 'You can only change your own kwento.';
  static const signInRequired = 'Sign in to continue.';
  static const postNotFound = 'That kwento is no longer available.';
  static const commentNotFound = 'That comment is no longer available.';
  static const profileNotFound = 'That profile is no longer available.';
  static const genericError = 'Something went wrong. Please try again.';
  static const networkError =
      'No connection. Check your internet and try again.';
  static const storageError = 'Image upload failed. Please try again.';

  static const connectionCheckTitle = 'Supabase connection';
  static const checkingConnection = 'Checking connection…';
  static const supabaseConnected = 'Supabase connected';
  static const supabaseConnectedDetail =
      'Client initialised, network reachable, posts table readable without signing in.';
  static const supabaseNotConfigured = 'Supabase is not configured';
  static const supabaseNotConfiguredDetail =
      'Run the app with --dart-define SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY.';
  static const supabaseUnreachable = 'Could not reach Supabase';
  static const recheck = 'Check again';

  static const writeAction = 'Write';
  static const homeTab = 'Home';
  static const profileTab = 'Profile';
  static const loadingMore = 'Loading more kwento…';
  static const endOfFeed = 'You’ve reached the end of the kwentuhan.';
  static const emptyFeed = 'Walang kwento pa — write the first one!';
  static const emptyFeedHint = 'Tap the pencil to start the kwentuhan.';
  static const retry = 'Try again';
  static const couldNotLoadMore = 'Could not load more kwento.';
  static const feedLoadFailed = 'Could not load the kwentuhan.';
  static const oneComment = '1 comment';
  static const noComments = 'No comments yet';
  static const justNow = 'just now';
  static const comments = 'Comments';
  static const joinKwentuhan = 'Join the kwentuhan…';
  static const post = 'Post';
  static const edit = 'Edit';
  static const delete = 'Delete';
  static const cancel = 'Cancel';

  static const newKwento = 'New kwento';
  static const editKwento = 'Edit kwento';
  static const titleLabel = 'Title';
  static const storyLabel = 'Story';
  static const imagesLabel = 'Images';
  static const addImage = '＋ Add';
  static const maxImagesNote = 'Max 6 images · up to 5 MB each · JPG or PNG';
  static const deletePost = 'Delete post';
  static const save = 'Save';
  static const saveChanges = 'Save changes';
  static const publish = 'Publish kwento';

  static const profileTitle = 'Profile';
  static const changePhoto = 'Change photo';
  static const removePhoto = 'Remove';
  static const emailLocked = 'Email can’t be changed';
  static const profileNote = 'Changes show on all your posts and comments.';

  static const kwentoLoadFailed = 'Could not load this kwento.';
  static const commentsLoadFailed = 'Could not load the kwentuhan.';
  static const emptyComments = 'Walang komento pa — start the kwentuhan.';
  static const signInToComment = 'Sign in to join the kwentuhan';
  static const signInToCommentHint =
      'Read freely — sign in when you want to reply.';
  static const commentRequired = 'Write something first.';
  static const deleteCommentTitle = 'Delete comment';
  static const deleteCommentMessage =
      'This removes the comment and its images. This cannot be undone.';
  static const attachImages = 'Attach images';
  static const removeImage = 'Remove image';
  static const someImagesSkipped =
      'Some images were skipped — JPG or PNG, up to 5 MB each.';

  static String commentsHeading(int count) => 'Comments ($count)';
  static String nameWithYou(String name) => '$name (you)';
  static String imageLimit(int max) => 'You can attach up to $max images.';

  static const titleRequired = 'Please add a title';
  static const storyRequired = 'Please write your kwento';
  static const deletePostMessage =
      'This removes the kwento, its images, and every comment on it. '
      'This cannot be undone.';
  static const closeEditor = 'Close';
  static const newImageBadge = 'NEW';

  static String imagesHeading(int count, int max) => 'Images ($count/$max)';

  static const profileLoadFailed = 'Could not load your profile.';
  static const profileUpdated = 'Profile updated';
  static const removePhotoTitle = 'Remove photo';
  static const removePhotoMessage =
      'Your profile will show your initials instead.';

  static const okAction = 'OK';
  static const signedInMessage = 'Signed in. Welcome back!';
  static const accountCreatedMessage = 'Account created. Welcome to Kwentapp!';

  static const deleteAccount = 'Delete account';
  static const deleteAccountTitle = 'Delete account?';
  static const deleteAccountMessage =
      'This permanently deletes your account and everything you posted — '
      'your kwento, comments, and images. This cannot be undone.';
}
