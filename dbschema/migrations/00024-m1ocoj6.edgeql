CREATE MIGRATION m1ocoj6avtydbu7r2lhoxvljexodewvj7cwk3xas6zqlfun37kkgvq
    ONTO m13cl6sgpknrvzb4tuaitcladesntbtwxrbatbbubdcosbupnsvf4q
{
  ALTER TYPE default::Primitive {
      CREATE MULTI LINK attachments -> default::Upload;
  };
};

# to apply before next migrations to update existing records

# FOR p IN Primitive
# UNION (
#     UPDATE Primitive
#     FILTER .id = p.id
#     SET {
#         attachments := (
#             SELECT Upload
#             FILTER .id IN p.uploads.id
#         )
#     }
# );