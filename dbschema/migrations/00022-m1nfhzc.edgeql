CREATE MIGRATION m1nfhzcxxy4q4q5bvhzaz2ts64lovrv3rmoeuitrdlb4e435wdby5a
    ONTO m17ltopayqneirzhnaqslwsbthbz3c47hnugdowukoe3xbav5h2y7a
{
  ALTER TYPE default::User {
      CREATE LINK imageUploaded -> default::Upload;
  };
};
