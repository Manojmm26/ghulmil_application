// =====================================
// GHULMIL APPLICATION - SUPABASE EDGE FUNCTIONS
// =====================================

/**
 * Edge Functions are serverless functions that run on Supabase's global edge network.
 * They handle complex business logic that can't be done efficiently in the database.
 */

// =====================================
// 1. BOOKING CREATION FUNCTION
// =====================================

export const createBooking = async (req: Request) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? ''
  );

  const { bookingDraft, paymentMethodId } = await req.json();

  // Start transaction
  const { data: booking, error: bookingError } = await supabase.rpc('create_booking_transaction', {
    booking_draft: bookingDraft,
    payment_method_id: paymentMethodId
  });

  if (bookingError) {
    return new Response(JSON.stringify({ error: bookingError }), { status: 400 });
  }

  // Find available providers
  const { data: providers, error: providersError } = await supabase.rpc('find_nearby_providers', {
    service_id_param: bookingDraft.serviceId,
    customer_location: `POINT(${bookingDraft.coordinates.longitude} ${bookingDraft.coordinates.latitude})`,
    max_distance_km: 50,
    limit_count: 5
  });

  if (providersError) {
    return new Response(JSON.stringify({ error: providersError }), { status: 400 });
  }

  // Assign first available provider or send to provider selection
  const providerId = providers[0]?.provider_id || null;

  // Update booking with provider
  const { data: updatedBooking, error: updateError } = await supabase
    .from('bookings')
    .update({ provider_id: providerId })
    .eq('id', booking.id)
    .select()
    .single();

  if (updateError) {
    return new Response(JSON.stringify({ error: updateError }), { status: 400 });
  }

  // Create notification for provider
  if (providerId) {
    await supabase.from('notifications').insert({
      user_id: providerId,
      type: 'booking',
      title: 'New Booking Request',
      message: `You have a new booking for ${bookingDraft.scheduledAt}`,
      data: { booking_id: booking.id }
    });
  }

  return new Response(JSON.stringify({ data: updatedBooking }), { status: 200 });
};

// =====================================
// 2. PAYMENT PROCESSING FUNCTION
// =====================================

export const processPayment = async (req: Request) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? ''
  );

  const { bookingId, paymentMethodId } = await req.json();

  // Get booking details
  const { data: booking, error: bookingError } = await supabase
    .from('bookings')
    .select('*')
    .eq('id', bookingId)
    .single();

  if (bookingError || !booking) {
    return new Response(JSON.stringify({ error: 'Booking not found' }), { status: 404 });
  }

  // Get payment method
  const { data: paymentMethod, error: paymentMethodError } = await supabase
    .from('payment_methods')
    .select('*')
    .eq('id', paymentMethodId)
    .single();

  if (paymentMethodError || !paymentMethod) {
    return new Response(JSON.stringify({ error: 'Payment method not found' }), { status: 404 });
  }

  // Process payment with Stripe
  const paymentIntent = await stripe.paymentIntents.create({
    amount: Math.round(booking.total_amount * 100), // Convert to cents
    currency: booking.currency,
    payment_method: paymentMethod.external_payment_id,
    confirm: true,
    metadata: {
      booking_id: bookingId
    }
  });

  // Record payment
  const { data: payment, error: paymentError } = await supabase
    .from('payments')
    .insert({
      booking_id: bookingId,
      payment_method_id: paymentMethodId,
      amount: booking.total_amount,
      currency: booking.currency,
      status: paymentIntent.status === 'succeeded' ? 'completed' : 'failed',
      external_payment_id: paymentIntent.id,
      payment_provider: 'stripe',
      processed_at: new Date()
    })
    .select()
    .single();

  if (paymentError) {
    return new Response(JSON.stringify({ error: paymentError }), { status: 400 });
  }

  // Update booking payment status
  await supabase
    .from('bookings')
    .update({ payment_status: payment.status === 'completed' ? 'paid' : 'failed' })
    .eq('id', bookingId);

  return new Response(JSON.stringify({ data: payment }), { status: 200 });
};

// =====================================
// 3. PROVIDER MATCHING FUNCTION
// =====================================

export const matchProviders = async (req: Request) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? ''
  );

  const { serviceId, scheduledAt, customerLocation, maxResults = 5 } = await req.json();

  const { data: providers, error } = await supabase.rpc('find_nearby_providers', {
    service_id_param: serviceId,
    customer_location: `POINT(${customerLocation.longitude} ${customerLocation.latitude})`,
    max_distance_km: 50,
    limit_count: maxResults
  });

  if (error) {
    return new Response(JSON.stringify({ error }), { status: 400 });
  }

  return new Response(JSON.stringify({ data: providers }), { status: 200 });
};

// =====================================
// 4. NOTIFICATION FUNCTION
// =====================================

export const sendNotification = async (req: Request) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? ''
  );

  const { userId, type, title, message, data = {} } = await req.json();

  const { error } = await supabase.from('notifications').insert({
    user_id: userId,
    type,
    title,
    message,
    data
  });

  if (error) {
    return new Response(JSON.stringify({ error }), { status: 400 });
  }

  // Send push notification if user has push tokens
  await sendPushNotification(userId, { title, message, data });

  return new Response(JSON.stringify({ success: true }), { status: 200 });
};

// =====================================
// 5. SUBSCRIPTION MANAGEMENT FUNCTION
// =====================================

export const manageSubscription = async (req: Request) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? ''
  );

  const { action, subscriptionId, updates } = await req.json();

  switch (action) {
    case 'create':
      return await createSubscription(updates);
    case 'update':
      return await updateSubscription(subscriptionId, updates);
    case 'cancel':
      return await cancelSubscription(subscriptionId);
    case 'pause':
      return await pauseSubscription(subscriptionId);
    default:
      return new Response(JSON.stringify({ error: 'Invalid action' }), { status: 400 });
  }
};

const createSubscription = async (subscriptionData: any) => {
  const { data, error } = await supabase
    .from('subscriptions')
    .insert(subscriptionData)
    .select()
    .single();

  if (error) {
    return new Response(JSON.stringify({ error }), { status: 400 });
  }

  // Schedule next booking
  await scheduleNextBooking(data.id);

  return new Response(JSON.stringify({ data }), { status: 200 });
};

// =====================================
// 6. ANALYTICS FUNCTION
// =====================================

export const getAnalytics = async (req: Request) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? ''
  );

  const { userId, userType, period = '30d' } = await req.json();

  let query = supabase
    .from('bookings')
    .select(`
      *,
      service:services(title),
      provider:providers(rating),
      review:reviews(rating)
    `);

  if (userType === 'customer') {
    query = query.eq('customer_id', userId);
  } else if (userType === 'provider') {
    query = query.eq('provider_id', userId);
  }

  const { data: bookings, error } = await query;

  if (error) {
    return new Response(JSON.stringify({ error }), { status: 400 });
  }

  // Calculate analytics
  const analytics = {
    totalBookings: bookings.length,
    completedBookings: bookings.filter(b => b.status === 'completed').length,
    cancelledBookings: bookings.filter(b => b.status === 'cancelled').length,
    averageRating: bookings
      .filter(b => b.review)
      .reduce((sum, b) => sum + b.review.rating, 0) / bookings.filter(b => b.review).length || 0,
    totalRevenue: bookings
      .filter(b => b.payment_status === 'paid')
      .reduce((sum, b) => sum + parseFloat(b.total_amount), 0),
    monthlyTrend: calculateMonthlyTrend(bookings)
  };

  return new Response(JSON.stringify({ data: analytics }), { status: 200 });
};

// =====================================
// 7. WEBHOOK HANDLER FUNCTION
// =====================================

export const handleWebhook = async (req: Request) => {
  const payload = await req.json();
  const eventType = req.headers.get('X-Event-Type') || payload.type;

  switch (eventType) {
    case 'booking.created':
      await handleBookingCreated(payload.data);
      break;
    case 'booking.updated':
      await handleBookingUpdated(payload.data);
      break;
    case 'payment.succeeded':
      await handlePaymentSucceeded(payload.data);
      break;
    case 'review.created':
      await handleReviewCreated(payload.data);
      break;
    default:
      console.log('Unhandled webhook event:', eventType);
  }

  return new Response(JSON.stringify({ received: true }), { status: 200 });
};

// =====================================
// HELPER FUNCTIONS
// =====================================

const sendPushNotification = async (userId: string, notification: any) => {
  // Implementation for push notifications (FCM, APNs)
  // This would integrate with Firebase Cloud Messaging or similar service
};

const scheduleNextBooking = async (subscriptionId: string) => {
  // Implementation for scheduling recurring bookings
  // This would integrate with a job queue system like Supabase Cron
};

const calculateMonthlyTrend = (bookings: any[]) => {
  // Calculate booking trends over time
  const monthlyData = {};
  // Implementation details...
  return monthlyData;
};

// Export all functions
export {
  createBooking,
  processPayment,
  matchProviders,
  sendNotification,
  manageSubscription,
  getAnalytics,
  handleWebhook
};
