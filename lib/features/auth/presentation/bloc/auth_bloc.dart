import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class SignInWithGoogle extends AuthEvent {}

class SignOut extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested(this.email, this.password);
  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  const SignUpRequested(this.email, this.password, this.name);
  @override
  List<Object> get props => [email, password, name];
}

class UpdateProfilePhoto extends AuthEvent {
  final String path;
  const UpdateProfilePhoto(this.path);
  @override
  List<Object> get props => [path];
}

class UpdateEmailRequested extends AuthEvent {
  final String newEmail;
  const UpdateEmailRequested(this.newEmail);
  @override
  List<Object> get props => [newEmail];
}

class UpdatePasswordRequested extends AuthEvent {
  final String newPassword;
  const UpdatePasswordRequested(this.newPassword);
  @override
  List<Object> get props => [newPassword];
}

class UpdateUsernameRequested extends AuthEvent {
  final String newName;
  const UpdateUsernameRequested(this.newName);
  @override
  List<Object> get props => [newName];
}

class DeleteAccountRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class SignUpSuccess extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SignOut>(_onSignOut);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<UpdateProfilePhoto>(_onUpdateProfilePhoto);
    on<UpdateEmailRequested>(_onUpdateEmailRequested);
    on<UpdatePasswordRequested>(_onUpdatePasswordRequested);
    on<UpdateUsernameRequested>(_onUpdateUsernameRequested);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final user = await repository.getCurrentUser();
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.signInWithGoogle();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthError("Google Sign-In canceled or failed"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.signIn(event.email, event.password);
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthError("Invalid email or password"));
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('OFFLINE_MODE')) {
        errorMessage = 'Offline mode: Backend server is not running.';
      } else {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.signUp(
        event.email,
        event.password,
        event.name,
      );
      if (user != null) {
        emit(SignUpSuccess());
      } else {
        emit(const AuthError("Sign up failed"));
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('OFFLINE_MODE')) {
        errorMessage = 'Offline mode: Backend server is not running.';
      } else {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    await repository.signOut();
    emit(Unauthenticated());
  }

  Future<void> _onUpdateProfilePhoto(
    UpdateProfilePhoto event,
    Emitter<AuthState> emit,
  ) async {
    await repository.updateProfilePhoto(event.path);
    final user = await repository.getCurrentUser();
    if (user != null) {
      emit(Authenticated(user));
    }
  }

  Future<void> _onUpdateEmailRequested(
    UpdateEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repository.updateEmail(event.newEmail);
    final user = await repository.getCurrentUser();
    if (user != null) {
      emit(Authenticated(user));
    }
  }

  Future<void> _onUpdatePasswordRequested(
    UpdatePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repository.updatePassword(event.newPassword);
    final user = await repository.getCurrentUser();
    if (user != null) {
      emit(Authenticated(user));
    }
  }

  Future<void> _onUpdateUsernameRequested(
    UpdateUsernameRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repository.updateDisplayName(event.newName);
    final user = await repository.getCurrentUser();
    if (user != null) {
      emit(Authenticated(user));
    }
  }

  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repository.deleteAccount();
    emit(Unauthenticated());
  }
}
