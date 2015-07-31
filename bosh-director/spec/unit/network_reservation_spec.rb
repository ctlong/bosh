require 'spec_helper'

module Bosh::Director
  describe NetworkReservation do
    let(:instance) { instance_double(DeploymentPlan::Instance) }

    describe :initialize do
      it 'should store the IP as an int' do
        reservation = NetworkReservation.new_static(instance, '0.0.0.1')
        expect(reservation.ip).to eq(1)
      end
    end

    describe :take do
      it "should take the dynamic reservation if it's valid" do
        reservation = NetworkReservation.new_dynamic(instance)
        other = NetworkReservation.new_dynamic(instance)
        other.reserve
        reservation.take(other)
        expect(reservation.reserved?).to eq(true)
      end

      it "should take the static reservation if it's valid" do
        reservation = NetworkReservation.new_static(instance, '0.0.0.1')
        other = NetworkReservation.new_static(instance, '0.0.0.1')
        other.reserve
        reservation.take(other)
        expect(reservation.reserved?).to eq(true)
        expect(reservation.ip).to eq(1)
      end

      it 'should not take the reservation if the type differs' do
        reservation = NetworkReservation.new_static(instance, '0.0.0.1')
        other = NetworkReservation.new_dynamic(instance)
        other.reserve
        reservation.take(other)
        expect(reservation.reserved?).to eq(false)
      end

      it 'should not take the static reservation if the IP differs' do
        reservation = NetworkReservation.new_static(instance, '0.0.0.1')
        other = NetworkReservation.new_static(instance, '0.0.0.2')
        other.reserve
        reservation.take(other)
        expect(reservation.reserved?).to eq(false)
        expect(reservation.ip).to eq(1)
      end

      it "should not take the reservation if it wasn't fulfilled" do
        reservation = NetworkReservation.new_dynamic(instance)
        other = NetworkReservation.new_static(instance, '0.0.0.1')
        reservation.take(other)
        expect(reservation.reserved?).to eq(false)
        expect(reservation.ip).to eq(nil)
      end
    end
  end
end
