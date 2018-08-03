# Eager loading a has_one with custom scope.

This is a standalone example from a real world app. In this example,
Clients have Orders, and we have a `recent_order` association that will
grab the most recent Order for a Client.

In ActiveRecord 4.2, the scope ordered the related Orders in descending
created_at order, but also made sure to limit the results to 1. For an
admin page that listed many Clients, we wanted to also show a piece of
data from the most recent Order per Client and so used an eager loading
`includes`. Everything worked fine.

After upgrading to 5.0 (testing showed the same behavior with 5.1 and
5.2), most of the `recent_order` instances returned were `nil`. After 
creating this standalone example, we realized what the issue was.

In 4.2, the explicit `limit(1)` clause in the custom scope of the
association was found to be superfluous. If we loaded the recent_order
for a single Client instance, ActiveRecord would emit a LIMIT 1 clause
in the underlying SQL _regardless_ of the presence of `limit(1)` in the
custom scope. If we eager loaded the recent_order for a set of Clients,
ActiveRecord 4.2 would NOT emit a LIMIT 1 clause for the eager query,
also regardless of the presence of `limit(1)` in the custom scope.

In 5.x, ActiveRecord no longer ignored the `limit(1)` in the eager load
case. It's hard to decide which version got this correct, as the
use-case is complicated, but the way this works in any version
(4.2-5.2) is to not include `limit(1)` and trust ActiveRecord to do
that right thing in the single instance case and the eager loaded set
case.